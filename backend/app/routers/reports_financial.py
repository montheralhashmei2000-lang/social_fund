# app/routers/reports_financial.py
"""القوائم المالية: ميزان المراجعة، قائمة الدخل، التدفقات النقدية، تقرير الحملة."""
from datetime import date
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User
from app.models.accounting import Account, JournalEntry, JournalLine, ACCOUNT_TYPES
from app.models.donations import Campaign
from app.services import export_service

router = APIRouter(prefix="/financial-reports", tags=["Financial Reports"])

DEBIT_NATURAL = {"asset", "expense"}


def _totals_in_range(db: Session, date_from: date, date_to: date):
    """لكل حساب: إجمالي مدين ودائن ضمن الفترة + الرصيد قبل الفترة (opening)."""
    rows = (
        db.query(
            Account,
            func.coalesce(func.sum(JournalLine.debit), 0),
            func.coalesce(func.sum(JournalLine.credit), 0),
        )
        .join(JournalLine, JournalLine.account_id == Account.id)
        .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
        .filter(JournalEntry.status == "posted", JournalEntry.entry_date <= date_to)
        .group_by(Account.id)
        .all()
    )
    out = {}
    for acc, dr, cr in rows:
        dr, cr = Decimal(str(dr)), Decimal(str(cr))
        opening_rows = (
            db.query(func.coalesce(func.sum(JournalLine.debit), 0), func.coalesce(func.sum(JournalLine.credit), 0))
            .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
            .filter(JournalEntry.status == "posted", JournalEntry.entry_date < date_from,
                    JournalLine.account_id == acc.id)
            .one()
        )
        opening = Decimal(str(opening_rows[0])) - Decimal(str(opening_rows[1]))
        out[acc.id] = {"account": acc, "debit": dr, "credit": cr, "opening": opening}
    return out


@router.get("/trial-balance")
def trial_balance(date_from: str = Query(...), date_to: str = Query(...),
                  format: str = Query("json"), db: Session = Depends(get_db), user: User = Depends(require_permission("reports"))):
    d_from, d_to = date.fromisoformat(date_from), date.fromisoformat(date_to)
    data = _totals_in_range(db, d_from, d_to)
    rows, total_dr, total_cr = [], Decimal(0), Decimal(0)
    for v in sorted(data.values(), key=lambda x: x["account"].code):
        net = v["debit"] - v["credit"]
        period_net = net  # يظهر بصف صافي
        rows.append([
            v["account"].code, v["account"].name, f"{float(v['debit']):,.2f}", f"{float(v['credit']):,.2f}",
            f"{float(net):,.2f}",
        ])
        total_dr += v["debit"]
        total_cr += v["credit"]

    if format == "pdf":
        pdf = export_service.generate_pdf_report(
            title=f"ميزان المراجعة ({date_from} ← {date_to})",
            headers=["الرمز", "الحساب", "مدين", "دائن", "الصافي"], rows=rows,
            fund_info={"name": _fund_name(db)})
        return Response(pdf, media_type="application/pdf",
                        headers={"Content-Disposition": "attachment; filename=trial_balance.pdf"})
    if format == "excel":
        xls = export_service.generate_excel_report(
            "ميزان المراجعة", ["الرمز", "الحساب", "مدين", "دائن", "الصافي"], rows)
        return Response(xls, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        headers={"Content-Disposition": "attachment; filename=trial_balance.xlsx"})

    return {
        "date_from": date_from, "date_to": date_to,
        "total_debit": float(total_dr), "total_credit": float(total_cr),
        "balanced": total_dr == total_cr,
        "rows": [
            {"code": v["account"].code, "account": v["account"].name,
             "debit": float(v["debit"]), "credit": float(v["credit"]),
             "net": float(v["debit"] - v["credit"])}
            for v in sorted(data.values(), key=lambda x: x["account"].code)
        ],
    }


@router.get("/income-statement")
def income_statement(date_from: str = Query(...), date_to: str = Query(...),
                     format: str = Query("json"), db: Session = Depends(get_db), user: User = Depends(require_permission("reports"))):
    d_from, d_to = date.fromisoformat(date_from), date.fromisoformat(date_to)
    data = _totals_in_range(db, d_from, d_to)
    income_rows, expense_rows = [], []
    total_income, total_expense = Decimal(0), Decimal(0)
    for v in data.values():
        acc = v["account"]
        if acc.type == "income":
            amt = v["credit"] - v["debit"]
            if amt != 0:
                income_rows.append({"account": acc.name, "code": acc.code, "amount": float(amt)})
                total_income += amt
        elif acc.type == "expense":
            amt = v["debit"] - v["credit"]
            if amt != 0:
                expense_rows.append({"account": acc.name, "code": acc.code, "amount": float(amt)})
                total_expense += amt

    if format == "pdf":
        pdf = export_service.generate_pdf_report(
            title=f"قائمة الدخل ({date_from} ← {date_to})",
            headers=["البيان", "المبلغ"],
            rows=[[r["account"], f"{r['amount']:,.2f}"] for r in income_rows + expense_rows] +
                 [["صافي الفائض (العجز)", f"{float(total_income - total_expense):,.2f}"]],
            fund_info={"name": _fund_name(db)})
        return Response(pdf, media_type="application/pdf",
                        headers={"Content-Disposition": "attachment; filename=income_statement.pdf"})

    return {
        "date_from": date_from, "date_to": date_to,
        "income": income_rows, "expenses": expense_rows,
        "total_income": float(total_income), "total_expense": float(total_expense),
        "net": float(total_income - total_expense),
    }


@router.get("/cash-flow")
def cash_flow(date_from: str = Query(...), date_to: str = Query(...),
              format: str = Query("json"), db: Session = Depends(get_db), user: User = Depends(require_permission("reports"))):
    """حركة الحسابات السائلة (بنوك/نقد/محافظ): رصيد افتتاحي + وارد + صادر + ختامي."""
    d_from, d_to = date.fromisoformat(date_from), date.fromisoformat(date_to)
    data = _totals_in_range(db, d_from, d_to)
    rows = []
    for v in sorted(data.values(), key=lambda x: x["account"].code):
        acc = v["account"]
        if not (acc.is_bank or acc.is_cash or acc.is_wallet):
            continue
        opening = v["opening"] if acc.type in DEBIT_NATURAL else -v["opening"]
        inflow, outflow = v["debit"], v["credit"]
        closing = opening + inflow - outflow
        rows.append({
            "account": acc.name, "code": acc.code,
            "opening": float(opening), "inflow": float(inflow),
            "outflow": float(outflow), "closing": float(closing),
        })

    if format == "pdf":
        pdf = export_service.generate_pdf_report(
            title=f"التدفقات النقدية ({date_from} ← {date_to})",
            headers=["الحساب", "افتتاحي", "وارد", "صادر", "ختامي"],
            rows=[[r["account"], f"{r['opening']:,.2f}", f"{r['inflow']:,.2f}",
                   f"{r['outflow']:,.2f}", f"{r['closing']:,.2f}"] for r in rows],
            fund_info={"name": _fund_name(db)})
        return Response(pdf, media_type="application/pdf",
                        headers={"Content-Disposition": "attachment; filename=cash_flow.pdf"})

    return {"date_from": date_from, "date_to": date_to, "rows": rows}


@router.get("/campaign/{campaign_id}")
def campaign_report(campaign_id: str, format: str = Query("json"), db: Session = Depends(get_db), user: User = Depends(require_permission("reports"))):
    from app.routers.campaigns import _progress
    c = db.query(Campaign).filter(Campaign.id == campaign_id).first()
    if not c:
        raise HTTPException(404, "الحملة غير موجودة")
    p = _progress(db, c)
    if format == "pdf":
        pdf = export_service.generate_pdf_report(
            title=f"تقرير الحملة: {c.name}",
            headers=["البيان", "القيمة"],
            rows=[
                ["الهدف", f"{p['goal']:,.2f}"],
                ["المجموع", f"{p['raised']:,.2f}"],
                ["المصروف", f"{p['spent']:,.2f}"],
                ["الصافي", f"{p['net']:,.2f}"],
                ["نسبة الإنجاز", f"{p['percent']}%"],
            ],
            fund_info={"name": _fund_name(db)})
        return Response(pdf, media_type="application/pdf",
                        headers={"Content-Disposition": "attachment; filename=campaign_report.pdf"})
    return p


def _fund_name(db: Session) -> str:
    from app.models.fund_settings import FundSettings
    f = db.query(FundSettings).first()
    return f.name if f else ""
