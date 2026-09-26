# app/services/otp_service.py
"""
رموز OTP: تخزين مجزّأ في قاعدة البيانات، توليد آمن، حذف فوري عند الاستخدام.

التحصينات (ملاحظتا الفحص 17 و18):
  - التوليد بـ secrets.randbelow بدل random.randint.
  - يُخزَّن SHA-256 للرمز (مع SECRET_KEY كفلفح) بدل النص الصريح - تسريب
    قاعدة البيانات لا يكشف الرموز.
  - يُحذف الصف فور نجاح التحقق (لا يُقبل التكرار ولا يبقى في الجدول)، ويُحذف
    الرمز السابق غير المستهلك عند إنشاء رمز جديد (رمز واحد نشط لكل مستخدم).
  - الإرسال: Twilio عند توفره. في وضع التطوير فقط يُطبع الرمز في الطرفية.
    في الإنتاج لا يُطبع الرمز أبداً - الفشل يعيد "failed" فيُعاد 503.
"""
import hashlib
import hmac
import logging
import secrets
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.otp_code import OtpCode

logger = logging.getLogger("otp_service")

OTP_TTL_SECONDS = 300

_twilio_client = None
_twilio_init_attempted = False


def _get_twilio_client():
    global _twilio_client, _twilio_init_attempted
    if _twilio_client is not None:
        return _twilio_client
    if _twilio_init_attempted:
        return None
    _twilio_init_attempted = True

    if not (settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_FROM_NUMBER):
        return None

    try:
        from twilio.rest import Client
        _twilio_client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    except Exception as e:
        logger.warning("فشل تهيئة عميل Twilio: %s", e)
        _twilio_client = None
    return _twilio_client


def _hash_code(code: str) -> str:
    return hashlib.sha256(f"{settings.SECRET_KEY}:{code}".encode()).hexdigest()


def create_otp(db: Session, user_id):
    """ينشئ رمز تحقق جديداً ويُرجع (otp_token, code). لا يعمل commit - المتحكم بالمسار يدير المعاملة."""
    # رمز واحد نشط لكل مستخدم: يُحذف الرمز السابق غير المستهلك.
    db.query(OtpCode).filter(
        OtpCode.user_id == user_id,
        OtpCode.consumed == False,  # noqa: E712
    ).delete(synchronize_session=False)

    code = f"{secrets.randbelow(1_000_000):06d}"
    token = str(uuid.uuid4())
    entry = OtpCode(
        token=token,
        user_id=user_id,
        code=_hash_code(code),
        expires_at=datetime.now(timezone.utc) + timedelta(seconds=OTP_TTL_SECONDS),
        consumed=False,
    )
    db.add(entry)
    db.flush()
    return token, code


def verify_otp(db: Session, token, code):
    """يتحقق من الرمز ويُرجع user_id عند النجاح أو None عند الفشل.

    النجاح يحذف الصف فوراً: الرمز يُستهلك مرة واحدة ولا يبقى في قاعدة البيانات.
    """
    entry = db.query(OtpCode).filter(OtpCode.token == token, OtpCode.consumed == False).first()  # noqa: E712
    if not entry:
        return None

    now = datetime.now(timezone.utc)
    expires_at = entry.expires_at if entry.expires_at.tzinfo else entry.expires_at.replace(tzinfo=timezone.utc)
    if expires_at < now:
        db.delete(entry)
        db.commit()
        return None

    if not hmac.compare_digest(entry.code, _hash_code(code or "")):
        return None

    user_id = str(entry.user_id)
    db.delete(entry)
    db.commit()
    return user_id


def cleanup_expired_otps(db: Session):
    """يحذف رموز OTP المنتهية من الجدول لمنع تراكمه (للاستدعاء الدوري من /admin/cleanup-otps)."""
    now = datetime.now(timezone.utc)
    deleted = db.query(OtpCode).filter(OtpCode.expires_at < now).delete(synchronize_session=False)  # noqa: E712
    db.commit()
    return deleted


def send_otp_sms(phone, code):
    """يُرسل الرمز عبر Twilio إن توفّر، ويُرجع "sent" أو "printed" (وضع التطوير) أو "failed".

    في الإنتاج لا يُطبع الرمز أبداً - الفشل يُسجَّل في السجلات دون الرمز نفسه.
    """
    client = _get_twilio_client()

    if client is None:
        if settings.ENV == "development":
            print(f"[OTP] (وضع التطوير - Twilio غير مضبوط) الرمز {code} لـ {phone or 'الهاتف المسجّل'}")
            return "printed"
        logger.error("Twilio غير مضبوط - تعذّر إرسال OTP (بيئة الإنتاج لا تطبع الرمز)")
        return "failed"

    if not phone:
        logger.warning("تعذّر إرسال OTP: لا يوجد رقم هاتف مسجّل للمستخدم")
        if settings.ENV == "development":
            print(f"[OTP] (وضع التطوير - لا هاتف مسجّل) الرمز {code}")
            return "printed"
        return "failed"

    to_number = phone if phone.startswith("+") else f"+967{phone.lstrip('0')}"

    try:
        client.messages.create(
            body=f"رمز التحقق الخاص بك في الصندوق الاجتماعي التنموي هو: {code}",
            from_=settings.TWILIO_FROM_NUMBER,
            to=to_number,
        )
        return "sent"
    except Exception as e:
        logger.error("فشل إرسال SMS إلى %s: %s", to_number, e)
        if settings.ENV == "development":
            print(f"[OTP] (وضع التطوير - فشل SMS) الرمز {code} لـ {phone}")
            return "printed"
        return "failed"
