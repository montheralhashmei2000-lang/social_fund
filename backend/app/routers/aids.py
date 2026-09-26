# app/routers/aids.py
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.deps import require_permission, get_client_ip
from app.models.member import Member
from app.models.records import AidRequest, AidStatus
from app.models.user import User, RoleEnum
from app.schemas.domain import AidCreate, AidStatusUpdate, AidOut
from app.services.audit_service import log_action
from app.services import push_service

router = APIRouter(prefix="/aids", tags=["Aid Requests"])

VALID_TRANSITIONS = {
    AidStatus.pending: {AidStatus.approved, AidStatus.rejected},
    AidStatus.approved: {AidStatus.disbursed, AidStatus.rejected},
    AidStatus.disbursed: set(),
    AidStatus.rejected: set(),
}


@router.get("", response_model=List[AidOut])
def list_aids(status_filter: Optional[str] = None, db: Session = Depends(get_db),
              user: User = Depends(require_permission("aids"))):
    q = db.query(AidRequest).filter(AidRequest.deleted == False)  # noqa: E712
    if status_filter:
        q = q.filter(AidRequest.status == status_filter)
    return q.order_by(AidRequest.request_date.desc()).all()


@router.post("", response_model=AidOut, status_code=status.HTTP_201_CREATED)
def create_aid(payload: AidCreate, request: Request, db: Session = Depends(get_db),
               user: User = Depends(require_permission("aids"))):
    member = db.query(Member).filter(Member.id == payload.member_id, Member.deleted == False).first()  # noqa: E712
    if not member:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")

    beneficiary = None
    if payload.beneficiary_id:
        from app.models.welfare import Beneficiary
        beneficiary = db.query(Beneficiary).filter(Beneficiary.id == payload.beneficiary_id).first()
        if not beneficiary:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "المستفيد غير موجود")

    aid = AidRequest(
        member_id=member.id, member_name=member.name, aid_type=payload.aid_type,
        amount=payload.amount, request_date=payload.request_date, note=payload.note,
        status=AidStatus.pending,
        created_by=user.id,
        beneficiary_id=payload.beneficiary_id,
    )
    db.add(aid)
    db.flush()
    log_action(db, user, "create", "aid_request", resource_id=aid.id,
               summary=f"طلب مساعدة جديد: {member.name} - {payload.aid_type} ({payload.amount} ﷼)",
               ip_address=get_client_ip(request))
    db.commit()
    db.refresh(aid)

    reviewer_ids = [
        u.id for u in db.query(User).filter(
            User.role.in_([RoleEnum.admin, RoleEnum.reviewer]),
            User.deleted == False,  # noqa: E712
            User.is_active == True,  # noqa: E712
        ).all()
    ]
    push_service.notify_new_aid_request(db, reviewer_ids, member.name, payload.aid_type, payload.amount, aid.id)

    return aid


@router.patch("/{aid_id}/status", response_model=AidOut)
def update_aid_status(aid_id: str, payload: AidStatusUpdate, request: Request,
                       db: Session = Depends(get_db), user: User = Depends(require_permission("aids"))):
    aid = db.query(AidRequest).filter(AidRequest.id == aid_id, AidRequest.deleted == False).first()  # noqa: E712
    if not aid:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "طلب المساعدة غير موجود")

    try:
        new_status = AidStatus(payload.status)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "حالة غير صالحة")

    if new_status not in VALID_TRANSITIONS.get(aid.status, set()):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"لا يمكن تغيير الحالة من '{aid.status.value}' إلى '{new_status.value}'",
        )

    # maker-checker: فصل المهام - من سجّل الطلب لا يعتمده بنفسه
    if new_status == AidStatus.approved and aid.created_by and str(aid.created_by) == str(user.id):
        raise HTTPException(
            status.HTTP_403_FORBIDDEN,
            "لا يمكنك اعتماد طلباً سجّلته بنفسك - يراجعه مستخدم آخر (فصل المهام)",
        )

    old_status = aid.status
    aid.status = new_status
    aid.reviewer_name = user.full_name
    aid.reviewer_id = user.id

    log_action(db, user, "update", "aid_request", resource_id=aid.id,
               summary=f"تحديث حالة طلب مساعدة {aid.member_name}: {old_status.value} إلى {new_status.value}",
               changes={"status": {"old": old_status.value, "new": new_status.value}},
               ip_address=get_client_ip(request))
    db.commit()
    db.refresh(aid)

    # إشعار المدراء بالقرار المتخذ (تأكيد للمتابعة، خصوصاً إن اتخذه مراجع
    # وليس المدير نفسه). الأعضاء أنفسهم لا يملكون حسابات دخول حالياً، لذا
    # لا يوجد طرف آخر لإشعاره مباشرة بنتيجة طلبه - راجع ملاحظة
    # notify_aid_status_changed في push_service.py لتفاصيل هذا القيد.
    admin_ids = [
        u.id for u in db.query(User).filter(
            User.role == RoleEnum.admin,
            User.deleted == False,  # noqa: E712
            User.is_active == True,  # noqa: E712
            User.id != user.id,  # لا داعي لإشعار المدير بقراره هو نفسه
        ).all()
    ]
    for admin_id in admin_ids:
        push_service.send_to_user(
            db, admin_id,
            title="تحديث حالة طلب مساعدة",
            body=f"{aid.member_name}: {old_status.value} ← {new_status.value} (بواسطة {user.full_name})",
            data={"type": "aid_status_changed", "aid_id": str(aid.id)},
        )

    return aid


@router.delete("/{aid_id}")
def delete_aid(aid_id: str, request: Request, db: Session = Depends(get_db),
               user: User = Depends(require_permission("aids"))):
    aid = db.query(AidRequest).filter(AidRequest.id == aid_id, AidRequest.deleted == False).first()  # noqa: E712
    if not aid:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "طلب المساعدة غير موجود")
    if aid.status == AidStatus.disbursed:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "لا يمكن حذف طلب تم صرفه بالفعل")

    aid.deleted = True
    log_action(db, user, "delete", "aid_request", resource_id=aid.id,
               summary=f"حذف طلب مساعدة: {aid.member_name}", ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم حذف الطلب"}
