# app/routers/campaigns.py
"""حملات جمع التبرعات: هدف + جُمع + مصروف + نسبة الإنجاز."""
from datetime import date
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.accounting import Account, JournalEntry, JournalLine
from app.models.donations import Campaign
from app.services.audit_service import log_action

router = APIRouter(prefix="/campaigns", tags=["Campaigns"])


class CampaignIn(BaseModel):
    name: str
    description: Optional[str] = None
    goal_amount: float
    start_date: str
    end_date: Optional[str] = None


def _progress(db: Session, c: Campaign):
    rows = (
        db.query(Account.type, func.coalesce(func.sum(JournalLine.debit), 0), func.coalesce(func.sum(JournalLine.credit), 0))
        .join(JournalLine, JournalLine.account_id == Account.id)
        .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
        .filter(JournalEntry.campaign_id == c.id, JournalEntry.status == "posted")
        .group_by(Account.type)
        .all()
    )
    raised = sum(Decimal(str(cr)) - Decimal(str(dr)) for t, dr, cr in rows if t == "income")
    spent = sum(Decimal(str(dr)) - Decimal(str(cr)) for t, dr, cr in rows if t == "expense")
    goal = Decimal(str(c.goal_amount))
    return {
        "raised": float(raised), "spent": float(spent), "net": float(raised - spent),
        "goal": float(goal),
        "percent": round(float(raised / goal * 100), 1) if goal > 0 else 0.0,
    }


def _campaign_out(db: Session, c: Campaign, with_progress: bool = True):
    out = {
        "id": str(c.id), "name": c.name, "description": c.description,
        "goal_amount": float(c.goal_amount),
        "start_date": c.start_date.isoformat(),
        "end_date": c.end_date.isoformat() if c.end_date else None,
        "status": c.status,
    }
    if with_progress:
        out.update(_progress(db, c))
    return out


@router.get("")
def list_campaigns(db: Session = Depends(get_db), user: User = Depends(require_permission("campaigns"))):
    return [_campaign_out(db, c) for c in db.query(Campaign).order_by(Campaign.start_date.desc()).all()]


@router.post("", status_code=status.HTTP_201_CREATED)
def create_campaign(payload: CampaignIn, db: Session = Depends(get_db), user: User = Depends(require_permission("campaigns"))):
    if payload.goal_amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "هدف الحملة يجب أن يكون أكبر من صفر")
    c = Campaign(
        name=payload.name, description=payload.description,
        goal_amount=Decimal(str(payload.goal_amount)),
        start_date=date.fromisoformat(payload.start_date),
        end_date=date.fromisoformat(payload.end_date) if payload.end_date else None,
        created_by=user.id,
    )
    db.add(c)
    log_action(db, user, "create", "campaign", resource_id=c.id, summary=f"إنشاء حملة: {c.name} بهدف {payload.goal_amount}")
    db.commit()
    return _campaign_out(db, c)


@router.get("/{campaign_id}")
def campaign_detail(campaign_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("campaigns"))):
    c = db.query(Campaign).filter(Campaign.id == campaign_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحملة غير موجودة")
    return _campaign_out(db, c)


@router.post("/{campaign_id}/close")
def close_campaign(campaign_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("campaigns"))):
    c = db.query(Campaign).filter(Campaign.id == campaign_id).first()
    if not c:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحملة غير موجودة")
    c.status = "closed"
    log_action(db, user, "update", "campaign", resource_id=c.id, summary=f"إغلاق حملة: {c.name}")
    db.commit()
    return {"message": "تم إغلاق الحملة"}
