# app/routers/admin.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User, RoleEnum
from app.services import reminder_service
from app.services.otp_service import cleanup_expired_otps

router = APIRouter(prefix="/admin", tags=["Admin"])


def require_admin(user: User = Depends(get_current_user)) -> User:
    if user.role != RoleEnum.admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "هذا الإجراء متاح لمدير النظام فقط")
    return user


@router.post("/run-reminders")
def run_reminders(db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    """
    يُشغّل كل التذكيرات الدورية (متأخرات الاشتراكات + المواعيد القادمة)
    مرة واحدة. مصمم ليُستدعى يومياً عبر مهمة cron خارجية - راجع التعليق
    التوضيحي في app/services/reminder_service.py لمثال جاهز.
    """
    result = reminder_service.run_all_reminders(db)
    return {"message": "تم تشغيل التذكيرات", **result}


@router.post("/cleanup-otps")
def cleanup_otps(db: Session = Depends(get_db), admin: User = Depends(require_admin)):
    """
    يحذف رموز OTP المنتهية/المُستهلَكة من قاعدة البيانات. مصمم أيضاً
    ليُستدعى دورياً (مثلاً أسبوعياً) عبر cron لمنع تراكم الجدول بلا داعٍ.
    """
    deleted = cleanup_expired_otps(db)
    return {"message": "تم تنظيف رموز التحقق المنتهية", "deleted_count": deleted}
