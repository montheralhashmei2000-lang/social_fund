# app/routers/auth.py
"""
المصادقة على خطوتين: كلمة مرور ← OTP ← رموز دخول.

تحصينات هذه النسخة (راجع تقرير الفحص الأمني):
  - refresh tokens تُخزَّن مجزّأة (SHA-256) في جدول refresh_sessions،
    تُدوَّر عند كل استخدام (rotation)، وتُلغى عند الخروج أو تغيير كلمة
    المرور أو إنهاء كل الأجهزة (الملاحظة 21).
  - access token قصير الأجل (ساعة) بدل 12 ساعة.
  - سياسة كلمة مرور: 8 أحرف كحد أدنى (الملاحظة 26).
  - إذا تعذر إرسال OTP عبر SMS فيُعاد 503 ولا يُطبع الرمز أبداً في الإنتاج
    (الملاحظتان 17 و18).
"""
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.config import settings
from app.core.security import (
    verify_password, hash_password, create_access_token,
    create_refresh_token, decode_token, hash_token,
)
from app.core.deps import get_current_user, get_client_ip
from app.models.user import User
from app.models.refresh_session import RefreshSession
from app.schemas.auth import (
    LoginRequest, LoginStep1Response, OtpVerifyRequest, TokenResponse,
    RefreshRequest, UserOut, ChangePasswordRequest, LogoutRequest,
)
from app.services.otp_service import create_otp, verify_otp, send_otp_sms
from app.services.audit_service import log_action
from app.services import rate_limit_service

router = APIRouter(prefix="/auth", tags=["Authentication"])

PASSWORD_MIN_LENGTH = 8


def _issue_session(db: Session, user: User, request: Request = None, device_id: str = None):
    """ينشئ access + refresh مع تسجيل جلسة refresh مجزّأة في قاعدة البيانات."""
    access_token = create_access_token({"sub": str(user.id), "role": user.role.value})
    refresh_token = create_refresh_token({"sub": str(user.id)})
    db.add(RefreshSession(
        user_id=user.id,
        token_hash=hash_token(refresh_token),
        device_id=device_id,
        ip_address=get_client_ip(request) if request else None,
        expires_at=datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    ))
    return access_token, refresh_token


def _revoke_by_token(db: Session, refresh_token: str) -> bool:
    row = db.query(RefreshSession).filter(
        RefreshSession.token_hash == hash_token(refresh_token),
        RefreshSession.revoked == False,  # noqa: E712
    ).first()
    if not row:
        return False
    row.revoked = True
    return True


@router.post("/login", response_model=LoginStep1Response)
def login(payload: LoginRequest, request: Request, db: Session = Depends(get_db)):
    ip = get_client_ip(request)

    allowed, remaining = rate_limit_service.check_allowed(ip, payload.username)
    if not allowed:
        minutes = max(1, remaining // 60)
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            f"تم حظر محاولات الدخول مؤقتاً بسبب تكرار المحاولات الفاشلة. حاول مجدداً بعد {minutes} دقيقة.",
        )

    user = db.query(User).filter(User.username == payload.username, User.deleted == False).first()  # noqa: E712

    if not user or not verify_password(payload.password, user.password_hash):
        rate_limit_service.record_failure(ip, payload.username)
        log_action(db, None, "login_failed", "auth",
                   summary=f"محاولة دخول فاشلة: {payload.username}", ip_address=ip)
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "اسم المستخدم أو كلمة المرور غير صحيحة")

    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "هذا الحساب معطّل، يرجى مراجعة مدير النظام")

    otp_token, code = create_otp(db, str(user.id))
    sms_status = send_otp_sms(user.phone, code)  # "sent" | "printed" | "failed"

    if sms_status == "failed":
        # لا نُبقي رمزاً لم يُرسَل، ولا نطبع الرمز في الإنتاج إطلاقاً.
        db.rollback()
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "تعذّر إرسال رمز التحقق عبر SMS حالياً. حاول لاحقاً أو راجع مدير النظام.",
        )

    db.commit()  # يثبّت رمز OTP في قاعدة البيانات - بدونه يُفقد عند إغلاق الجلسة (rollback ضمني)

    return LoginStep1Response(
        requires_otp=True,
        otp_token=otp_token,
        user_name=user.full_name,
        phone_hint=f"***{user.phone[-4:]}" if user.phone else None,
    )


@router.post("/verify-otp", response_model=TokenResponse)
def verify_otp_login(payload: OtpVerifyRequest, request: Request, db: Session = Depends(get_db)):
    ip = get_client_ip(request)

    allowed, remaining = rate_limit_service.check_allowed(ip, payload.otp_token)
    if not allowed:
        minutes = max(1, remaining // 60)
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            f"تم حظر محاولات التحقق مؤقتاً بسبب تكرار المحاولات الفاشلة. حاول مجدداً بعد {minutes} دقيقة.",
        )

    # حد إضافي لكل رمز تحقق بغض النظر عن IP (ترويسة X-Forwarded-For قابلة للتزوير)
    allowed_tok, _ = rate_limit_service.check_allowed(None, payload.otp_token)
    if not allowed_tok:
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS,
                            "تم حظر محاولات التحقق مؤقتاً بسبب تكرار المحاولات الفاشلة.")

    user_id = verify_otp(db, payload.otp_token, payload.code)
    if not user_id:
        rate_limit_service.record_failure(ip, payload.otp_token)
        rate_limit_service.record_failure(None, payload.otp_token)
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "رمز التحقق غير صحيح أو منتهي الصلاحية")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "المستخدم غير موجود")

    rate_limit_service.record_success(ip, payload.otp_token)
    rate_limit_service.record_success(ip, user.username)

    access_token, refresh_token = _issue_session(db, user, request, device_id=payload.device_id)

    log_action(db, user, "login", "auth", resource_id=user.id,
               summary=f"تسجيل دخول ناجح: {user.username}",
               ip_address=ip, device_id=payload.device_id)
    db.commit()

    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(payload: RefreshRequest, request: Request, db: Session = Depends(get_db)):
    """تدوير الـrefresh token: القديم يُلغى فور استخدامه ويصدر بديلاً عنه.

    إعادة استخدام refresh token أُلغي سابقاً تُرفض فوراً - أي نسخة مسروقة
    تفقد قيمتها بعد أول تحديث للجلسة.
    """
    data = decode_token(payload.refresh_token or "")
    if not data or data.get("type") != "refresh":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "رمز التحديث غير صالح")

    row = db.query(RefreshSession).filter(
        RefreshSession.token_hash == hash_token(payload.refresh_token)
    ).first()
    if not row or row.revoked:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "انتهت الجلسة، يرجى تسجيل الدخول من جديد")

    expires_at = row.expires_at if row.expires_at.tzinfo else row.expires_at.replace(tzinfo=timezone.utc)
    if expires_at < datetime.now(timezone.utc):
        row.revoked = True
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "انتهت الجلسة، يرجى تسجيل الدخول من جديد")

    user = db.query(User).filter(User.id == data.get("sub"), User.deleted == False).first()  # noqa: E712
    if not user or not user.is_active:
        row.revoked = True
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "المستخدم غير موجود أو معطّل")

    row.revoked = True  # rotation: يُلغى القديم
    access_token, new_refresh = _issue_session(db, user, request, device_id=row.device_id)
    db.commit()
    return TokenResponse(access_token=access_token, refresh_token=new_refresh)


@router.get("/me", response_model=UserOut)
def get_me(user: User = Depends(get_current_user)):
    return UserOut(
        id=str(user.id), username=user.username, full_name=user.full_name,
        role=user.role.value, avatar_initial=user.avatar_initial, phone=user.phone,
    )


@router.post("/change-password")
def change_password(payload: ChangePasswordRequest, request: Request,
                    user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not verify_password(payload.old_password, user.password_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "كلمة المرور الحالية غير صحيحة")
    if len(payload.new_password) < PASSWORD_MIN_LENGTH:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"كلمة المرور الجديدة يجب أن تكون {PASSWORD_MIN_LENGTH} أحرف على الأقل",
        )

    user.password_hash = hash_password(payload.new_password)

    # تغيير كلمة المرور ينهي جلسات التحديث على كل الأجهزة.
    db.query(RefreshSession).filter(
        RefreshSession.user_id == user.id,
        RefreshSession.revoked == False,  # noqa: E712
    ).update({"revoked": True})

    log_action(db, user, "update", "user", resource_id=user.id,
               summary="تغيير كلمة المرور (إلغاء كل الجلسات النشطة)",
               ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم تغيير كلمة المرور وتم إنهاء الجلسات على جميع الأجهزة"}


@router.post("/logout")
def logout(payload: LogoutRequest, request: Request,
           user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """تسجيل خروج الجهاز الحالي: يُلغي refresh token المُمرَّر فعلياً في قاعدة البيانات."""
    revoked = False
    if payload.refresh_token:
        revoked = _revoke_by_token(db, payload.refresh_token)
    log_action(db, user, "logout", "auth", resource_id=user.id,
               summary=f"تسجيل خروج: {user.username}", ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم تسجيل الخروج", "session_revoked": revoked}


@router.post("/logout-all")
def logout_all(request: Request, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """إنهاء كل جلسات المستخدم على جميع الأجهزة (مثلاً عند فقدان أو سرقة جهاز)."""
    count = db.query(RefreshSession).filter(
        RefreshSession.user_id == user.id,
        RefreshSession.revoked == False,  # noqa: E712
    ).update({"revoked": True})
    log_action(db, user, "logout_all", "auth", resource_id=user.id,
               summary=f"إنهاء جميع الجلسات ({count}) للمستخدم {user.username}",
               ip_address=get_client_ip(request))
    db.commit()
    return {"message": f"تم إنهاء {count} جلسة على جميع الأجهزة", "sessions_revoked": count}
