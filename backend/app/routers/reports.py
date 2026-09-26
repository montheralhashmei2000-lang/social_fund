# app/routers/reports.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
import io

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.member import Member
from app.models.records import Subscription, AidRequest, TreasuryEntry, Voucher
from app.models.fund_settings import FundSettings
from app.models.user import User
from app.services.export_service import generate_pdf_report, generate_excel_report
from app.services.audit_service import log_action

router = APIRouter(prefix="/reports", tags=["Reports"])

REPORT_DEFS = {
    "members": {
        "title": "تقرير الأعضاء",
        "headers": ["الاسم", "المدينة", "الحالة", "الاشتراك الشهري", "إجمالي المدفوع", "المتأخرات"],
        "model": Member,
        "row": lambda m: [m.name, m.city or "-", m.status.value, m.monthly_subscription, m.total_paid, m.balance_due],
    },
    "subscriptions": {
        "title": "تقرير الاشتراكات",
        "headers": ["العضو", "المبلغ", "التاريخ", "طريقة الدفع", "رقم المرجع"],
        "model": Subscription,
        "row": lambda s: [s.member_name, s.amount, s.payment_date, s.method, s.reference_no or "-"],
    },
    "aids": {
        "title": "تقرير طلبات المساعدة",
        "headers": ["العضو", "النوع", "المبلغ", "التاريخ", "الحالة", "المراجع"],
        "model": AidRequest,
        "row": lambda a: [a.member_name, a.aid_type, a.amount, a.request_date, a.status.value, a.reviewer_name or "-"],
    },
    "treasury": {
        "title": "تقرير الخزينة",
        "headers": ["النوع", "التصنيف", "الوصف", "المبلغ", "التاريخ", "رقم المرجع"],
        "model": TreasuryEntry,
        "row": lambda t: [t.type.value, t.category, t.description, t.amount, t.entry_date, t.reference_no or "-"],
    },
    "vouchers": {
        "title": "تقرير السندات",
        "headers": ["رقم السند", "النوع", "العضو", "المبلغ", "التاريخ", "الحالة"],
        "model": Voucher,
        "row": lambda v: [v.voucher_no, v.kind.value, v.member_name, v.amount, v.voucher_date, v.status],
    },
}


def _get_fund_info(db: Session) -> dict:
    row = db.query(FundSettings).first()
    if not row:
        return {"name": "الصندوق الاجتماعي التنموي"}
    return {"name": row.name, "phone": row.phone, "email": row.email}


@router.get("/{report_key}/pdf")
def export_pdf(report_key: str, db: Session = Depends(get_db),
                user: User = Depends(require_permission("reports"))):
    definition = REPORT_DEFS.get(report_key)
    if not definition:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "تقرير غير معروف")

    records = db.query(definition["model"]).filter(definition["model"].deleted == False).all()  # noqa: E712
    rows = [definition["row"](r) for r in records]

    pdf_bytes = generate_pdf_report(
        title=definition["title"], headers=definition["headers"], rows=rows,
        fund_info=_get_fund_info(db),
    )

    log_action(db, user, "export", report_key, summary=f"تصدير {definition['title']} بصيغة PDF")
    db.commit()

    return StreamingResponse(
        io.BytesIO(pdf_bytes), media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{report_key}_report.pdf"'},
    )


@router.get("/{report_key}/excel")
def export_excel(report_key: str, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("reports"))):
    definition = REPORT_DEFS.get(report_key)
    if not definition:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "تقرير غير معروف")

    records = db.query(definition["model"]).filter(definition["model"].deleted == False).all()  # noqa: E712
    rows = [definition["row"](r) for r in records]

    excel_bytes = generate_excel_report(title=definition["title"], headers=definition["headers"], rows=rows)

    log_action(db, user, "export", report_key, summary=f"تصدير {definition['title']} بصيغة Excel")
    db.commit()

    return StreamingResponse(
        io.BytesIO(excel_bytes),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{report_key}_report.xlsx"'},
    )
