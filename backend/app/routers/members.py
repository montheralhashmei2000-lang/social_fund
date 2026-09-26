# app/routers/members.py
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.deps import require_permission, get_client_ip
from app.core.encryption import search_hash
from app.models.member import Member
from app.models.user import User
from app.schemas.domain import MemberCreate, MemberUpdate, MemberOut
from app.services.audit_service import log_action

router = APIRouter(prefix="/members", tags=["Members"])


@router.get("", response_model=List[MemberOut])
def list_members(db: Session = Depends(get_db), user: User = Depends(require_permission("members"))):
    return db.query(Member).filter(Member.deleted == False).order_by(Member.name).all()  # noqa: E712


@router.get("/{member_id}", response_model=MemberOut)
def get_member(member_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("members"))):
    m = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
    if not m:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")
    return m


@router.post("", response_model=MemberOut, status_code=status.HTTP_201_CREATED)
def create_member(payload: MemberCreate, request: Request, db: Session = Depends(get_db),
                   user: User = Depends(require_permission("members"))):
    id_hash = search_hash(payload.national_id)
    exists = db.query(Member).filter(Member.national_id_search == id_hash, Member.deleted == False).first()  # noqa: E712
    if exists:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "رقم الهوية مسجّل مسبقاً لعضو آخر")

    member = Member(**payload.model_dump(), national_id_search=id_hash)
    db.add(member)
    db.flush()
    log_action(db, user, "create", "member", resource_id=member.id,
               summary=f"إضافة عضو جديد: {member.name}", ip_address=get_client_ip(request))
    db.commit()
    db.refresh(member)
    return member


@router.put("/{member_id}", response_model=MemberOut)
def update_member(member_id: str, payload: MemberUpdate, request: Request, db: Session = Depends(get_db),
                   user: User = Depends(require_permission("members"))):
    member = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
    if not member:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")

    changes = {}
    updates = payload.model_dump(exclude_unset=True)
    for field, new_val in updates.items():
        old_val = getattr(member, field)
        old_val_str = old_val.value if hasattr(old_val, "value") else old_val
        if old_val_str != new_val:
            changes[field] = {"old": old_val_str, "new": new_val}
        setattr(member, field, new_val)

    if updates.get("national_id"):
        member.national_id_search = search_hash(updates["national_id"])

    if changes:
        log_action(db, user, "update", "member", resource_id=member.id,
                   summary=f"تحديث بيانات العضو: {member.name}", changes=changes,
                   ip_address=get_client_ip(request))
    db.commit()
    db.refresh(member)
    return member


@router.delete("/{member_id}")
def delete_member(member_id: str, request: Request, db: Session = Depends(get_db),
                   user: User = Depends(require_permission("members"))):
    member = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
    if not member:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")

    member.deleted = True
    log_action(db, user, "delete", "member", resource_id=member.id,
               summary=f"حذف العضو: {member.name}", ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم حذف العضو"}
