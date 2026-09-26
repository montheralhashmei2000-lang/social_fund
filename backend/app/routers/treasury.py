# app/routers/treasury.py
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.deps import require_permission, get_client_ip
from app.models.records import TreasuryEntry, TreasuryType
from app.models.user import User
from app.schemas.domain import TreasuryCreate, TreasuryOut
from app.services.audit_service import log_action

router = APIRouter(prefix="/treasury", tags=["Treasury"])


def next_reference_no(db: Session) -> str:
    count = db.query(TreasuryEntry).count()
    return f"TR-{count + 1:03d}"


@router.get("", response_model=List[TreasuryOut])
def list_entries(db: Session = Depends(get_db), user: User = Depends(require_permission("treasury"))):
    return db.query(TreasuryEntry).filter(TreasuryEntry.deleted == False).order_by(TreasuryEntry.entry_date.desc()).all()  # noqa: E712


@router.post("", response_model=TreasuryOut, status_code=status.HTTP_201_CREATED)
def create_entry(payload: TreasuryCreate, request: Request, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("treasury"))):
    try:
        TreasuryType(payload.type)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "نوع المعاملة يجب أن يكون إيراد أو مصروف")

    entry = TreasuryEntry(
        type=payload.type, category=payload.category, description=payload.description,
        amount=payload.amount, entry_date=payload.entry_date, reference_no=next_reference_no(db),
    )
    db.add(entry)
    db.flush()
    log_action(db, user, "create", "treasury_entry", resource_id=entry.id,
               summary=f"معاملة خزينة: {payload.type} - {payload.description} ({payload.amount} ﷼)",
               ip_address=get_client_ip(request))
    db.commit()
    db.refresh(entry)
    return entry


@router.delete("/{entry_id}")
def delete_entry(entry_id: str, request: Request, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("treasury"))):
    entry = db.query(TreasuryEntry).filter(TreasuryEntry.id == entry_id, TreasuryEntry.deleted == False).first()  # noqa: E712
    if not entry:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المعاملة غير موجودة")

    entry.deleted = True
    log_action(db, user, "delete", "treasury_entry", resource_id=entry.id,
               summary=f"حذف معاملة خزينة: {entry.description}", ip_address=get_client_ip(request))
    db.commit()
    return {"message": "تم حذف المعاملة"}
