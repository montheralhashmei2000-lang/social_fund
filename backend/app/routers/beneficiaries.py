# app/routers/beneficiaries.py
"""المستفيدون (دراسات الحالة) + المساعدات الدورية (المعاشات)."""
from datetime import date
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.core.encryption import search_hash
from app.models.user import User
from app.models.welfare import Beneficiary, PeriodicAid
from app.services.audit_service import log_action

router = APIRouter(tags=["Beneficiaries & Periodic Aid"])


class BeneficiaryIn(BaseModel):
    full_name: str
    national_id: Optional[str] = None
    phone: Optional[str] = None
    family_size: int = 1
    monthly_income: float = 0
    housing: Optional[str] = None
    case_summary: Optional[str] = None
    status: str = "active"


class PeriodicAidIn(BaseModel):
    beneficiary_id: str
    monthly_amount: float
    started_on: str
    notes: Optional[str] = None


class PeriodicPayIn(BaseModel):
    period: str  # YYYY-MM
    from_account_id: str  # حساب الأصول الذي سيخصم منه
    expense_account_id: str  # حساب مصروف المساعدات


def _beneficiary_out(b: Beneficiary):
    return {
        "id": str(b.id), "full_name": b.full_name, "national_id": b.national_id,
        "phone": b.phone, "family_size": b.family_size,
        "monthly_income": float(b.monthly_income or 0), "housing": b.housing,
        "case_summary": b.case_summary, "status": b.status,
    }


@router.get("/beneficiaries")
def list_beneficiaries(q: Optional[str] = None, db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    query = db.query(Beneficiary).order_by(Beneficiary.full_name)
    if q:
        query = query.filter(Beneficiary.full_name.contains(q))
    return [_beneficiary_out(b) for b in query.limit(300).all()]


@router.post("/beneficiaries", status_code=status.HTTP_201_CREATED)
def create_beneficiary(payload: BeneficiaryIn, db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    id_hash = search_hash(payload.national_id) if payload.national_id else None
    if id_hash and db.query(Beneficiary).filter(Beneficiary.national_id_search == id_hash).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "رقم الهوية مسجّل مسبقاً لمستفيد آخر")
    b = Beneficiary(**payload.model_dump(), national_id_search=id_hash, registered_by=user.id)
    db.add(b)
    log_action(db, user, "create", "beneficiary", resource_id=b.id, summary=f"تسجيل مستفيد: {b.full_name}")
    db.commit()
    return _beneficiary_out(b)


@router.put("/beneficiaries/{beneficiary_id}")
def update_beneficiary(beneficiary_id: str, payload: BeneficiaryIn, db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    b = db.query(Beneficiary).filter(Beneficiary.id == beneficiary_id).first()
    if not b:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المستفيد غير موجود")
    updates = payload.model_dump()
    if updates.get("national_id"):
        b.national_id_search = search_hash(updates["national_id"])
    for k, v in updates.items():
        setattr(b, k, v)
    log_action(db, user, "update", "beneficiary", resource_id=b.id, summary=f"تحديث بيانات المستفيد: {b.full_name}")
    db.commit()
    return _beneficiary_out(b)


# ================= المساعدات الدورية =================

@router.get("/periodic-aids")
def list_periodic_aids(db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    rows = db.query(PeriodicAid, Beneficiary).join(Beneficiary, PeriodicAid.beneficiary_id == Beneficiary.id).all()
    return [
        {
            "id": str(p.id), "beneficiary_id": str(b.id), "beneficiary_name": b.full_name,
            "monthly_amount": float(p.monthly_amount), "started_on": p.started_on.isoformat(),
            "status": p.status, "last_paid_period": p.last_paid_period, "notes": p.notes,
        }
        for p, b in rows
    ]


@router.get("/periodic-aids/due")
def due_periodic_aids(db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    """معاشات مستحقة عن الشهر الحالي أو سابقة ولم تُصرف."""
    period = date.today().strftime("%Y-%m")
    rows = db.query(PeriodicAid, Beneficiary).join(Beneficiary, PeriodicAid.beneficiary_id == Beneficiary.id).filter(
        PeriodicAid.status == "active"
    ).all()
    out = []
    for p, b in rows:
        if not p.last_paid_period or p.last_paid_period < period:
            out.append({
                "id": str(p.id), "beneficiary_id": str(b.id), "beneficiary_name": b.full_name,
                "monthly_amount": float(p.monthly_amount), "last_paid_period": p.last_paid_period,
                "due_period": period,
            })
    return out


@router.post("/periodic-aids", status_code=status.HTTP_201_CREATED)
def create_periodic_aid(payload: PeriodicAidIn, db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    if not db.query(Beneficiary).filter(Beneficiary.id == payload.beneficiary_id).first():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المستفيد غير موجود")
    if payload.monthly_amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ الشهري يجب أن يكون أكبر من صفر")
    p = PeriodicAid(
        beneficiary_id=payload.beneficiary_id, monthly_amount=Decimal(str(payload.monthly_amount)),
        started_on=date.fromisoformat(payload.started_on), notes=payload.notes,
    )
    db.add(p)
    log_action(db, user, "create", "periodic_aid", resource_id=p.id,
               summary=f"مساعدة دورية جديدة بمبلغ شهري {payload.monthly_amount}")
    db.commit()
    return {
        "id": str(p.id), "beneficiary_id": str(p.beneficiary_id),
        "monthly_amount": float(p.monthly_amount), "started_on": p.started_on.isoformat(),
        "status": p.status, "last_paid_period": p.last_paid_period, "notes": p.notes,
        "message": "تم إنشاء المساعدة الدورية",
    }


@router.post("/periodic-aids/{aid_id}/pay")
def pay_periodic_aid(aid_id: str, payload: PeriodicPayIn, db: Session = Depends(get_db), user: User = Depends(require_permission("beneficiaries"))):
    """صرف معاش شهر: قيد مزدوج (مدين مصروف / دائن حساب الدفع) + تحديث آخر فترة مسددة."""
    from app.models.accounting import JournalEntry, JournalLine, Account
    from sqlalchemy import func

    p = db.query(PeriodicAid).filter(PeriodicAid.id == aid_id).first()
    if not p:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المساعدة الدورية غير موجودة")
    if p.status != "active":
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المساعدة الدورية معلقة")

    period = payload.period
    if not (len(period) == 7 and period[:4].isdigit() and period[5:7].isdigit()):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة الفترة غير صحيحة (YYYY-MM)")
    if p.last_paid_period and p.last_paid_period >= period:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"فترة {period} مصروفة مسبقاً (آخر صرف: {p.last_paid_period})")

    expense_acc = db.query(Account).filter(Account.id == payload.expense_account_id).first()
    from_acc = db.query(Account).filter(Account.id == payload.from_account_id).first()
    if not expense_acc or not from_acc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "أحد الحسابات غير موجود")

    b = db.query(Beneficiary).filter(Beneficiary.id == p.beneficiary_id).first()
    amount = p.monthly_amount
    entry = JournalEntry(
        entry_no="TMP", entry_date=date.today(), entry_type="periodic_aid",
        description=f"صرف مساعدة دورية ({period}) - {b.full_name if b else ''}",
        status="posted", beneficiary_id=p.beneficiary_id, created_by=user.id,
    )
    db.add(entry)
    db.flush()
    from app.services.sequence_service import next_entry_no
    entry.entry_no = next_entry_no(db)
    db.add_all([
        JournalLine(entry_id=entry.id, account_id=expense_acc.id, debit=amount, credit=0),
        JournalLine(entry_id=entry.id, account_id=from_acc.id, debit=0, credit=amount),
    ])
    p.last_paid_period = period
    log_action(db, user, "create", "journal_entry", resource_id=entry.id,
               summary=f"صرف معاش {period} بمبلغ {amount} للمستفيد {b.full_name if b else ''}")
    db.commit()
    return {"message": "تم الصرف", "entry_no": entry.entry_no}
