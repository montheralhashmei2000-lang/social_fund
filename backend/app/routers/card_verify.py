# app/routers/card_verify.py
"""
التحقق الميداني من بطاقة العضوية: تُمسح بطاقة QR في التطبيق (عند صرف مساعدة
مثلاً) فيُستدعى هذا المسار ليعيد حالة العضوية الفعلية من الخادم — بدل أن
تبقى البطاقة عرضاً فقط. الإذن: أذون "aids" (من يصرف يتحقق).
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.member import Member
from app.models.user import User

router = APIRouter(prefix="/members", tags=["Card Verification"])


@router.get("/{member_id}/card-verify")
def verify_card(member_id: str, db: Session = Depends(get_db),
                user: User = Depends(require_permission("aids"))):
    m = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
    if not m:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود - البطاقة غير صالحة")

    member_status = getattr(m, "status", None)
    is_active = member_status == "نشط" if member_status else bool(getattr(m, "is_active", True))
    return {
        "id": str(m.id),
        "name": m.name,
        "status": member_status or ("نشط" if is_active else "معلق"),
        "verified": is_active,
        "total_paid": getattr(m, "total_paid", 0) or 0,
        "balance_due": getattr(m, "balance_due", 0) or 0,
        "monthly_subscription": getattr(m, "monthly_subscription", 0) or 0,
    }
