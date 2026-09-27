# app/routers/donors.py
"""المانحون (تجار، مؤسسات، محسنون) + الوعود + شهادات الشكر."""
from datetime import date
from decimal import Decimal
from io import BytesIO
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.accounting import JournalEntry, JournalLine, Account
from app.models.donations import Donor, Pledge, DONOR_TYPES, DONOR_TIERS, PLEDGE_FREQUENCIES
from app.services.audit_service import log_action

router = APIRouter(tags=["Donors & Pledges"])


class DonorIn(BaseModel):
    name: str
    donor_type: str = "individual"
    tier: str = "silver"
    phone: Optional[str] = None
    email: Optional[str] = None
    notes: Optional[str] = None
    is_active: bool = True


class PledgeIn(BaseModel):
    donor_id: str
    amount: float
    frequency: str = "monthly"
    start_date: str
    end_date: Optional[str] = None
    notes: Optional[str] = None


def _donor_out(db: Session, d: Donor, total_override=None):
    if total_override is not None:
        total = total_override
    else:
        total = db.query(func.coalesce(func.sum(JournalLine.credit - JournalLine.debit), 0)).join(
            JournalEntry, JournalLine.entry_id == JournalEntry.id
        ).filter(
            JournalEntry.donor_id == d.id,
            JournalEntry.status == "posted",
            JournalLine.credit > 0,
        ).scalar() or 0
    return {
        "id": str(d.id), "name": d.name, "donor_type": d.donor_type,
        "donor_type_label": DONOR_TYPES.get(d.donor_type, d.donor_type),
        "tier": d.tier, "tier_label": DONOR_TIERS.get(d.tier, d.tier),
        "phone": d.phone, "email": d.email, "notes": d.notes,
        "is_active": d.is_active, "total_donated": float(total),
    }


def _pledge_out(p: Pledge, donor_name: str = ""):
    return {
        "id": str(p.id), "donor_id": str(p.donor_id), "donor_name": donor_name,
        "amount": float(p.amount), "frequency": p.frequency,
        "frequency_label": PLEDGE_FREQUENCIES.get(p.frequency, p.frequency),
        "start_date": p.start_date.isoformat(),
        "end_date": p.end_date.isoformat() if p.end_date else None,
        "status": p.status, "last_fulfilled_on": p.last_fulfilled_on.isoformat() if p.last_fulfilled_on else None,
        "notes": p.notes,
    }


def _next_due(p: Pledge) -> date:
    """أقرب تاريخ استحقاق تالٍ بحسب دورية الوعد."""
    base = p.last_fulfilled_on or p.start_date
    if p.frequency == "monthly":
        m = base.month + 1
        return date(base.year + (m - 1) // 12, (m - 1) % 12 + 1, base.day)
    if p.frequency == "quarterly":
        m = base.month + 3
        return date(base.year + (m - 1) // 12, (m - 1) % 12 + 1, base.day)
    if p.frequency == "annual":
        return date(base.year + 1, base.month, base.day)
    return p.start_date  # مرة واحدة: تستحق في تاريخ البداية


@router.get("/donors")
def list_donors(db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    """قائمة المانحين بإجمالي التبرعات — استعلام مجمّع واحد بدل استعلام لكل مانح (N+1)."""
    totals = (
        db.query(JournalEntry.donor_id.label("did"),
                 func.coalesce(func.sum(JournalLine.credit - JournalLine.debit), 0).label("total"))
        .join(JournalLine, JournalLine.entry_id == JournalEntry.id)
        .filter(JournalEntry.status == "posted", JournalLine.credit > 0, JournalEntry.donor_id.isnot(None))
        .group_by(JournalEntry.donor_id)
        .all()
    )
    totals_map = {str(t.did): float(t.total) for t in totals}
    out = []
    for d in db.query(Donor).order_by(Donor.name).all():
        item = _donor_out(db, d, total_override=totals_map.get(str(d.id), 0.0))
        out.append(item)
    return out


@router.post("/donors", status_code=status.HTTP_201_CREATED)
def create_donor(payload: DonorIn, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    if payload.donor_type not in DONOR_TYPES or payload.tier not in DONOR_TIERS:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "نوع أو مستوى مانح غير صالح")
    d = Donor(**payload.model_dump())
    db.add(d)
    db.flush()
    log_action(db, user, "create", "donor", resource_id=d.id, summary=f"إضافة مانح: {d.name}")
    db.commit()
    return _donor_out(db, d)


@router.get("/donors/{donor_id}")
def donor_detail(donor_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    d = db.query(Donor).filter(Donor.id == donor_id).first()
    if not d:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")

    donations = (
        db.query(JournalEntry, JournalLine)
        .join(JournalLine, JournalLine.entry_id == JournalEntry.id)
        .filter(JournalEntry.donor_id == d.id, JournalEntry.status == "posted", JournalLine.credit > 0)
        .order_by(JournalEntry.entry_date.desc())
        .all()
    )
    pledges = db.query(Pledge).filter(Pledge.donor_id == d.id).order_by(Pledge.start_date.desc()).all()
    out = _donor_out(db, d)
    out["donations"] = [
        {"entry_no": e.entry_no, "entry_date": e.entry_date.isoformat(),
         "description": e.description, "amount": float(l.credit)}
        for e, l in donations
    ]
    out["pledges"] = [_pledge_out(p, d.name) for p in pledges]
    return out


@router.put("/donors/{donor_id}")
def update_donor(donor_id: str, payload: DonorIn, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    d = db.query(Donor).filter(Donor.id == donor_id).first()
    if not d:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")
    for k, v in payload.model_dump().items():
        setattr(d, k, v)
    log_action(db, user, "update", "donor", resource_id=d.id, summary=f"تحديث بيانات المانح: {d.name}")
    db.commit()
    return _donor_out(db, d)


@router.delete("/donors/{donor_id}")
def delete_donor(donor_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    d = db.query(Donor).filter(Donor.id == donor_id).first()
    if not d:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")
    d.is_active = False
    log_action(db, user, "delete", "donor", resource_id=d.id, summary=f"تعطيل المانح: {d.name}")
    db.commit()
    return {"message": "تم تعطيل المانح"}


@router.get("/donors/{donor_id}/certificate")
def thank_you_certificate(donor_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    """شهادة شكر PDF باسم المانح وإجمالي تبرعاته — بشعار وبيانات الصندوق."""
    from app.services.export_service import generate_pdf_report
    from app.models.fund_settings import FundSettings

    d = db.query(Donor).filter(Donor.id == donor_id).first()
    if not d:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")

    total = db.query(func.coalesce(func.sum(JournalLine.credit), 0)).join(
        JournalEntry, JournalLine.entry_id == JournalEntry.id
    ).filter(JournalEntry.donor_id == d.id, JournalEntry.status == "posted").scalar() or 0

    fund = db.query(FundSettings).first()
    pdf = generate_pdf_report(
        title=f"شهادة شكر وتقدير - {d.name}",
        headers=["البيان", "القيمة"],
        rows=[
            ["اسم المانح", f"{d.name} ({DONOR_TIERS.get(d.tier, d.tier)})"],
            ["تصنيف المانح", DONOR_TYPES.get(d.donor_type, d.donor_type)],
            ["إجمالي التبرعات", f"{float(total):,.2f} ريال"],
            ["تاريخ الإصدار", date.today().isoformat()],
        ],
        fund_info={"name": fund.name if fund else "", "phone": getattr(fund, "phone", None), "email": getattr(fund, "email", None)},
    )
    log_action(db, user, "export", "donor", resource_id=d.id, summary=f"إصدار شهادة شكر للمانح: {d.name}")
    db.commit()
    return Response(
        content=pdf, media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename=thank_you_certificate.pdf"},
    )


# ================= الوعود =================

@router.get("/pledges")
def list_pledges(status_filter: Optional[str] = None, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    rows = db.query(Pledge, Donor).join(Donor, Pledge.donor_id == Donor.id).order_by(Pledge.start_date.desc()).all()
    out = []
    for p, d in rows:
        if status_filter and p.status != status_filter:
            continue
        item = _pledge_out(p, d.name)
        item["next_due"] = _next_due(p).isoformat() if p.status == "active" else None
        out.append(item)
    return out


@router.get("/pledges/due")
def due_pledges(db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    """الوعود النشطة المستحقة اليوم أو المتأخرة — للتذكير والتحصيل."""
    today = date.today()
    rows = db.query(Pledge, Donor).join(Donor, Pledge.donor_id == Donor.id).filter(Pledge.status == "active").all()
    out = []
    for p, d in rows:
        due = _next_due(p)
        if due <= today:
            item = _pledge_out(p, d.name)
            item["next_due"] = due.isoformat()
            item["days_overdue"] = (today - due).days
            out.append(item)
    return out


@router.post("/pledges", status_code=status.HTTP_201_CREATED)
def create_pledge(payload: PledgeIn, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    if payload.frequency not in PLEDGE_FREQUENCIES:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "دورية الوعد غير صالحة")
    if not db.query(Donor).filter(Donor.id == payload.donor_id).first():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")
    if payload.amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ يجب أن يكون أكبر من صفر")
    p = Pledge(
        donor_id=payload.donor_id, amount=Decimal(str(payload.amount)),
        frequency=payload.frequency, start_date=date.fromisoformat(payload.start_date),
        end_date=date.fromisoformat(payload.end_date) if payload.end_date else None,
        notes=payload.notes,
    )
    db.add(p)
    log_action(db, user, "create", "pledge", resource_id=p.id, summary=f"وعد تبرع جديد بمبلغ {payload.amount}")
    db.commit()
    return _pledge_out(p)


@router.post("/pledges/{pledge_id}/fulfill")
def fulfill_pledge(pledge_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    p = db.query(Pledge).filter(Pledge.id == pledge_id).first()
    if not p:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الوعد غير موجود")
    p.last_fulfilled_on = date.today()
    if p.frequency == "one_time" or (p.end_date and date.today() >= p.end_date):
        p.status = "completed"
    db.commit()
    return {"message": "تم تسجيل الوفاء بالوعد"}
