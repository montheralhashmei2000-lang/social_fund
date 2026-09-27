# app/routers/journal.py
"""دفتر القيد المزدوج: كل قيد يجب أن يتوازن (مجموع المدين = مجموع الدائن)."""
from datetime import date
from decimal import Decimal
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Response, status
from pydantic import BaseModel, field_validator
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.accounting import JournalEntry, JournalLine, Account, ENTRY_TYPES
from app.services import sequence_service  # noqa: F401 (يسجل نموذج العدادات)
from app.services.audit_service import log_action

router = APIRouter(prefix="/journal", tags=["Journal (Double Entry)"])


class LineIn(BaseModel):
    account_id: str
    debit: float = 0
    credit: float = 0
    memo: Optional[str] = None


class EntryIn(BaseModel):
    entry_date: str
    description: str
    entry_type: str
    reference: Optional[str] = None
    campaign_id: Optional[str] = None
    donor_id: Optional[str] = None
    member_id: Optional[str] = None
    aid_id: Optional[str] = None
    beneficiary_id: Optional[str] = None
    status: str = "posted"  # posted / draft
    lines: List[LineIn]

    @field_validator("lines")
    @classmethod
    def at_least_two_lines(cls, v):
        if len(v) < 2:
            raise ValueError("القيد يحتاج سطرين على الأقل (مدين ودائن)")
        return v


def _entry_out(db: Session, e: JournalEntry):
    lines = (
        db.query(JournalLine, Account)
        .join(Account, JournalLine.account_id == Account.id)
        .filter(JournalLine.entry_id == e.id)
        .all()
    )
    total = sum(Decimal(str(l.debit)) for l, _ in lines)
    return {
        "id": str(e.id), "entry_no": e.entry_no, "entry_date": e.entry_date.isoformat(),
        "description": e.description, "entry_type": e.entry_type,
        "entry_type_label": ENTRY_TYPES.get(e.entry_type, e.entry_type),
        "reference": e.reference, "status": e.status,
        "campaign_id": str(e.campaign_id) if e.campaign_id else None,
        "donor_id": str(e.donor_id) if e.donor_id else None,
        "member_id": str(e.member_id) if e.member_id else None,
        "total": float(total),
        "lines": [
            {
                "id": str(l.id), "account_id": str(a.id), "account_code": a.code,
                "account_name": a.name, "debit": float(l.debit), "credit": float(l.credit),
                "memo": l.memo,
            }
            for l, a in lines
        ],
    }


@router.get("")
def list_entries(date_from: Optional[str] = None, date_to: Optional[str] = None,
                 entry_type: Optional[str] = None, status_filter: Optional[str] = None,
                 campaign_id: Optional[str] = None, donor_id: Optional[str] = None,
                 limit: Optional[int] = None, offset: int = 0,
                 response: Response = None, db: Session = Depends(get_db),
                 user: User = Depends(require_permission("accounting"))):
    q = db.query(JournalEntry).order_by(JournalEntry.entry_date.desc(), JournalEntry.created_at.desc())
    if date_from:
        q = q.filter(JournalEntry.entry_date >= date.fromisoformat(date_from))
    if date_to:
        q = q.filter(JournalEntry.entry_date <= date.fromisoformat(date_to))
    if entry_type:
        q = q.filter(JournalEntry.entry_type == entry_type)
    if status_filter:
        q = q.filter(JournalEntry.status == status_filter)
    if campaign_id:
        q = q.filter(JournalEntry.campaign_id == campaign_id)
    if donor_id:
        q = q.filter(JournalEntry.donor_id == donor_id)
    total = q.count()
    if response is not None:
        response.headers["X-Total-Count"] = str(total)
    if limit:
        q = q.offset(offset).limit(limit)
    return [_entry_out(db, e) for e in q.all()]


@router.get("/entry-types")
def entry_types():
    return [{"key": k, "label": v} for k, v in ENTRY_TYPES.items()]


@router.post("", status_code=status.HTTP_201_CREATED)
def create_entry(payload: EntryIn, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    if payload.entry_type not in ENTRY_TYPES:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "نوع القيد غير صالح")

    total_debit = sum(Decimal(str(l.debit)) for l in payload.lines)
    total_credit = sum(Decimal(str(l.credit)) for l in payload.lines)
    if total_debit <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "إجمالي القيد يجب أن يكون أكبر من صفر")
    if total_debit != total_credit:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"القيد غير متوازن: مدين {total_debit} ≠ دائن {total_credit}",
        )
    for l in payload.lines:
        if (l.debit > 0 and l.credit > 0) or (l.debit == 0 and l.credit == 0):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "كل سطر إما مدين أو دائن وليس الاثنين معاً أو صفراً")
        if not db.query(Account).filter(Account.id == l.account_id).first():
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "أحد الحسابات غير موجود")

    try:
        entry_date = date.fromisoformat(payload.entry_date)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة التاريخ غير صحيحة")

    entry = JournalEntry(
        entry_no="TMP", entry_date=entry_date, description=payload.description,
        entry_type=payload.entry_type, reference=payload.reference,
        status=payload.status if payload.status in ("posted", "draft") else "posted",
        campaign_id=payload.campaign_id, donor_id=payload.donor_id,
        member_id=payload.member_id, aid_id=payload.aid_id,
        beneficiary_id=payload.beneficiary_id, created_by=user.id,
    )
    db.add(entry)
    db.flush()
    from app.services.sequence_service import next_number
    entry.entry_no = f"JE-{next_number(db, 'journal_entry'):06d}"
    db.add_all([
        JournalLine(entry_id=entry.id, account_id=l.account_id,
                    debit=Decimal(str(l.debit)), credit=Decimal(str(l.credit)), memo=l.memo)
        for l in payload.lines
    ])
    log_action(db, user, "create", "journal_entry", resource_id=entry.id,
               summary=f"قيد {entry.entry_no} ({ENTRY_TYPES[payload.entry_type]}) بمبلغ {total_debit}")
    db.commit()
    return _entry_out(db, entry)


@router.post("/{entry_id}/void")
def void_entry(entry_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    """إبطال مسموح للمسودات فقط — القيد المُرحَّل لا يُحذف (يوثق بالمراجعة)."""
    entry = db.query(JournalEntry).filter(JournalEntry.id == entry_id).first()
    if not entry:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "القيد غير موجود")
    if entry.status == "posted":
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                            "لا يمكن إبطال قيد مُرحَّل — أنشئ قيد تسوية عكسي بدلاً منه")
    entry.status = "void"
    log_action(db, user, "update", "journal_entry", resource_id=entry.id,
               summary=f"إبطال المسودة {entry.entry_no}")
    db.commit()
    return {"message": "تم إبطال المسودة"}
