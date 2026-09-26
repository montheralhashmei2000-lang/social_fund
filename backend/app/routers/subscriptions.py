# app/routers/subscriptions.py
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.deps import require_permission, get_client_ip
from app.models.member import Member
from app.models.records import Subscription
from app.models.user import User
from app.schemas.domain import SubscriptionCreate, SubscriptionOut
from app.services.audit_service import log_action

router = APIRouter(prefix="/subscriptions", tags=["Subscriptions"])


def next_reference_no(db: Session) -> str:
    count = db.query(Subscription).count()
    return f"RCP-{count + 1:03d}"


@router.get("", response_model=List[SubscriptionOut])
def list_subscriptions(db: Session = Depends(get_db), user: User = Depends(require_permission("subscriptions"))):
    return db.query(Subscription).filter(Subscription.deleted == False).order_by(Subscription.payment_date.desc()).all()  # noqa: E712


@router.post("", response_model=SubscriptionOut, status_code=status.HTTP_201_CREATED)
def create_subscription(payload: SubscriptionCreate, request: Request, db: Session = Depends(get_db),
                         user: User = Depends(require_permission("subscriptions"))):
    member = db.query(Member).filter(Member.id == payload.member_id, Member.deleted == False).first()  # noqa: E712
    if not member:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")
    if payload.amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ يجب أن يكون أكبر من صفر")

    sub = Subscription(
        member_id=member.id, member_name=member.name, amount=payload.amount,
        payment_date=payload.payment_date, method=payload.method,
        reference_no=next_reference_no(db),
    )
    db.add(sub)

    member.total_paid = (member.total_paid or 0) + payload.amount
    member.balance_due = max(0, (member.balance_due or 0) - payload.amount)

    db.flush()
    log_action(db, user, "create", "subscription", resource_id=sub.id,
               summary=f"تسجيل اشتراك: {member.name} - {payload.amount} ﷼",
               ip_address=get_client_ip(request))
    db.commit()
    db.refresh(sub)
    return sub


@router.delete("/{sub_id}")
def delete_subscription(sub_id: str, request: Request, db: Session = Depends(get_db),
                         user: User = Depends(require_permission("subscriptions"))):
    sub = db.query(Subscription).filter(Subscription.id == sub_id, Subscription.deleted == False).first()  # noqa: E712
    if not sub:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الاشتراك غير موجود")

    member = db.query(Member).filter(Member.id == sub.member_id).first()
    if member:
        member.total_paid = max(0, (member.total_paid or 0) - sub.amount)
        member.balance_due = (member.balance_due or 0) + sub.amount

    sub.deleted = True
    log_action(db, user, "delete", "subscription", resource_id=sub.id,
               summary=f"حذف اشتراك: {sub.member_name} - {sub.amount} ﷼",
               ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم حذف الاشتراك"}
