# app/routers/budgets.py
"""الموازنات الشهرية مقابل الفعلي (من قيود اليومية)."""
from typing import Optional

from sqlalchemy import func

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.accounting import Account, JournalEntry, JournalLine
from app.models.welfare import Budget
from app.services.audit_service import log_action

router = APIRouter(prefix="/budgets", tags=["Budgets"])


class BudgetIn(BaseModel):
    period: str  # YYYY-MM
    account_id: str
    planned_amount: float


@router.get("/{period}/report")
def budget_report(period: str, db: Session = Depends(get_db), user: User = Depends(require_permission("budgets"))):
    budgets = db.query(Budget, Account).join(Account, Budget.account_id == Account.id).filter(Budget.period == period).all()
    rows, total_planned, total_actual = [], 0.0, 0.0
    for b, acc in budgets:
        actual = (
            db.query(JournalLine)
            .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
            .filter(
                JournalLine.account_id == acc.id,
                JournalEntry.status == "posted",
                JournalEntry.entry_type.in_(["expense", "aid_disbursement", "periodic_aid"]),
                func.strftime("%Y-%m", JournalEntry.entry_date).label("m") == period
                if db.bind.dialect.name == "sqlite" else
                func.to_char(JournalEntry.entry_date, "YYYY-MM") == period,
            )
            .with_entities(func.coalesce(func.sum(JournalLine.debit - JournalLine.credit), 0))
            .scalar() or 0
        )
        planned = float(b.planned_amount)
        actual = float(actual)
        rows.append({
            "account_id": str(acc.id), "account_code": acc.code, "account_name": acc.name,
            "planned": planned, "actual": actual,
            "usage_pct": round(actual / planned * 100, 1) if planned > 0 else 0.0,
        })
        total_planned += planned
        total_actual += actual
    return {
        "period": period, "rows": rows,
        "total_planned": total_planned, "total_actual": total_actual,
        "total_usage_pct": round(total_actual / total_planned * 100, 1) if total_planned > 0 else 0.0,
    }



@router.post("", status_code=status.HTTP_201_CREATED)
def create_budget(payload: BudgetIn, db: Session = Depends(get_db), user: User = Depends(require_permission("budgets"))):
    if not (len(payload.period) == 7 and payload.period[:4].isdigit() and payload.period[5:7].isdigit()):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة الفترة غير صحيحة (YYYY-MM)")
    acc = db.query(Account).filter(Account.id == payload.account_id).first()
    if not acc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "حساب الموازنة غير موجود")
    if payload.planned_amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ المخطط يجب أن يكون أكبر من صفر")
    if db.query(Budget).filter(Budget.period == payload.period, Budget.account_id == acc.id).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "توجد موازنة لنفس الحساب في نفس الفترة")
    b = Budget(period=payload.period, account_id=acc.id,
               planned_amount=__import__("decimal").Decimal(str(payload.planned_amount)), created_by=user.id)
    db.add(b)
    log_action(db, user, "create", "budget", resource_id=b.id,
               summary=f"موازنة {payload.period} لـ {acc.name}: {payload.planned_amount}")
    db.commit()
    return {"message": "تم إنشاء الموازنة"}


@router.delete("/{budget_id}")
def delete_budget(budget_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("budgets"))):
    b = db.query(Budget).filter(Budget.id == budget_id).first()
    if not b:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الموازنة غير موجودة")
    db.delete(b)
    db.commit()
    return {"message": "تم حذف الموازنة"}
