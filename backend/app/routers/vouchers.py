# app/routers/vouchers.py
"""
سندات القبض والصرف — مربوطة بالبنية المعمارية للنظام كاملة:

- كل سند يولّد قيد يومية متوازناً تلقائياً:
    سند قبض: مدين حساب الخزينة/البنك، دائن الحساب المقابل (إيراد/حساب الطرف).
    سند صرف: مدين الحساب المقابل (مصروف)، دائن حساب الخزينة/البنك.
  القيد يحمل ارتباطات الطرف (عضو/مانح/مستفيد) فتظهر السندات تلقائياً في
  دفتر القيود، شجرة الحسابات، القوائم المالية وتقارير الحملات والمانحين.
- كل سند يُنشئ معاملة خزينة مرآتية (reference_no = رقم السند) تغذي شاشة
  الخزينة ولوحة المعلومات دون أي إدخال مزدوج.
- الطرف: عضو أو مانح أو مستفيد أو جهة حرة (نص حر).
- الإلغاء بقيد عكسي (القيد المُرحَّل لا يُحذف أبداً) مع تعطيل مرآة الخزينة.
- PDF رسمي للسند ببيانات الصندوق.
"""
from datetime import date, datetime
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_client_ip, require_permission
from app.models.accounting import Account, JournalEntry, JournalLine
from app.models.donations import Donor
from app.models.member import Member
from app.models.records import TreasuryEntry, TreasuryType, Voucher, VoucherKind
from app.models.user import User
from app.models.welfare import Beneficiary
from app.services import sequence_service  # noqa: F401 (يسجل نموذج العدادات)
from app.services.audit_service import log_action

router = APIRouter(prefix="/vouchers", tags=["Vouchers"])

RECEIPT = VoucherKind.receipt.value
PAYMENT = VoucherKind.payment.value
VOUCHER_ENTRY_TYPE = {RECEIPT: "voucher_receipt", PAYMENT: "voucher_payment"}


def next_voucher_no(db: Session, kind: str) -> str:
    from app.services.sequence_service import next_number
    prefix = "REC" if kind == RECEIPT else "PAY"
    year = datetime.utcnow().year
    seq = next_number(db, "voucher_" + ("receipt" if kind == RECEIPT else "payment"))
    return f"{prefix}-{year}-{seq:04d}"


def _next_entry_no(db: Session) -> str:
    seq = (db.query(func.count(JournalEntry.id)).scalar() or 0) + 1
    return f"JE-{seq:06d}"


def _party(db: Session, member_id, donor_id, beneficiary_id, party_name):
    """تحديد طرف السند (عضو/مانح/مستفيد/جهة حرة) — يعيد (الاسم، ارتباطات القيد)."""
    if member_id:
        m = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
        if not m:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود")
        return m.name, {"member_id": m.id}
    if donor_id:
        d = db.query(Donor).filter(Donor.id == donor_id).first()
        if not d:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "المانح غير موجود")
        return d.name, {"donor_id": d.id}
    if beneficiary_id:
        b = db.query(Beneficiary).filter(Beneficiary.id == beneficiary_id).first()
        if not b:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "المستفيد غير موجود")
        return b.full_name, {"beneficiary_id": b.id}
    if party_name and party_name.strip():
        return party_name.strip(), {}
    raise HTTPException(status.HTTP_400_BAD_REQUEST,
                        "حدد طرف السند: عضو أو مانح أو مستفيد أو جهة حرة")


def _voucher_out(db: Session, v: Voucher):
    entry_no = None
    if v.journal_entry_id:
        e = db.query(JournalEntry).filter(JournalEntry.id == v.journal_entry_id).first()
        entry_no = e.entry_no if e else None
    return {
        "id": str(v.id), "voucher_no": v.voucher_no, "kind": v.kind.value if isinstance(v.kind, VoucherKind) else v.kind,
        "member_id": str(v.member_id) if v.member_id else None,
        "member_name": v.member_name or "",
        "donor_id": str(v.donor_id) if v.donor_id else None,
        "beneficiary_id": str(v.beneficiary_id) if v.beneficiary_id else None,
        "party_name": v.party_name,
        "amount": v.amount, "voucher_date": v.voucher_date, "method": v.method,
        "description": v.description, "issued_by_name": v.issued_by_name, "status": v.status,
        "treasury_account_id": str(v.treasury_account_id) if v.treasury_account_id else None,
        "counter_account_id": str(v.counter_account_id) if v.counter_account_id else None,
        "journal_entry_id": str(v.journal_entry_id) if v.journal_entry_id else None,
        "journal_entry_no": entry_no,
    }


@router.get("")
def list_vouchers(kind: Optional[str] = None, member_id: Optional[str] = None,
                  donor_id: Optional[str] = None, beneficiary_id: Optional[str] = None,
                  limit: Optional[int] = None, offset: int = 0,
                  response: Response = None, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("vouchers"))):
    q = db.query(Voucher).filter(Voucher.deleted == False)  # noqa: E712
    if kind:
        q = q.filter(Voucher.kind == kind)
    if member_id:
        q = q.filter(Voucher.member_id == member_id)
    if donor_id:
        q = q.filter(Voucher.donor_id == donor_id)
    if beneficiary_id:
        q = q.filter(Voucher.beneficiary_id == beneficiary_id)
    q = q.order_by(Voucher.voucher_date.desc())
    total = q.count()
    if response is not None:
        response.headers["X-Total-Count"] = str(total)
    if limit:
        q = q.offset(offset).limit(limit)
    return [_voucher_out(db, v) for v in q.all()]


@router.post("", status_code=status.HTTP_201_CREATED)
def create_voucher(payload: dict, request: Request, db: Session = Depends(get_db),
                   user: User = Depends(require_permission("vouchers"))):
    """إصدار سند: طرف + حساب خزينة + حساب مقابل → قيد مزدوج متوازن + مرآة خزينة."""
    from app.schemas.domain import VoucherCreate

    try:
        data = VoucherCreate(**payload)
    except Exception:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "بيانات السند غير مكتملة")

    try:
        kind = VoucherKind(data.kind)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "نوع السند يجب أن يكون قبض أو صرف")
    if data.amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ يجب أن يكون أكبر من صفر")
    try:
        vdate = date.fromisoformat(data.voucher_date)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة التاريخ غير صحيحة")
    if data.treasury_account_id == data.counter_account_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "اختر حسابين مختلفين للسند")

    party_name, links = _party(db, data.member_id, data.donor_id, data.beneficiary_id, data.party_name)
    treasury_acc = db.query(Account).filter(Account.id == data.treasury_account_id).first()
    counter_acc = db.query(Account).filter(Account.id == data.counter_account_id).first()
    if not treasury_acc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "حساب الخزينة/البنك غير موجود")
    if not counter_acc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحساب المقابل غير موجود")

    # حماية من السحب فوق الرصيد: سند صرف على حساب أصول لا يتجاوز رصيده
    if kind == VoucherKind.payment and (treasury_acc.type or "") == "asset":
        bal_rows = (db.query(JournalLine.debit, JournalLine.credit)
                    .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
                    .filter(JournalLine.account_id == treasury_acc.id,
                            JournalEntry.status == "posted").all())
        bal = sum(Decimal(str(d or 0)) for d, _ in bal_rows) - sum(Decimal(str(c or 0)) for _, c in bal_rows)
        if bal < Decimal(str(data.amount)):
            raise HTTPException(status.HTTP_400_BAD_REQUEST,
                                f"رصيد الحساب غير كافٍ للمصروف: المتاح {bal} والمطلوب {data.amount}")
    is_receipt = kind == VoucherKind.receipt
    if is_receipt and not (treasury_acc.is_bank or treasury_acc.is_cash or treasury_acc.is_wallet):
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                            "حساب قبض النقود يجب أن يكون صندوق نقدي أو بنك أو محفظة")

    voucher = Voucher(
        voucher_no=next_voucher_no(db, kind.value),
        kind=kind, member_name=party_name, party_name=party_name,
        amount=data.amount, voucher_date=data.voucher_date, method=data.method,
        description=data.description, issued_by_name=user.full_name, issued_by_id=user.id,
        status="معتمد",
        treasury_account_id=treasury_acc.id, counter_account_id=counter_acc.id,
        **links,
    )
    db.add(voucher)
    db.flush()

    # ===== القيد المزدوج =====
    amount = Decimal(str(data.amount))
    entry = JournalEntry(
        entry_no="TMP", entry_date=vdate,
        description=f"سند {kind.value} {voucher.voucher_no} — {party_name}: {data.description}"[:250],
        entry_type=VOUCHER_ENTRY_TYPE[kind.value], reference=voucher.voucher_no,
        status="posted", created_by=user.id, **links,
    )
    db.add(entry)
    db.flush()
    entry.entry_no = _next_entry_no(db)
    if is_receipt:
        debit_acc, credit_acc = treasury_acc, counter_acc
    else:
        debit_acc, credit_acc = counter_acc, treasury_acc
    db.add_all([
        JournalLine(entry_id=entry.id, account_id=debit_acc.id, debit=amount, credit=0),
        JournalLine(entry_id=entry.id, account_id=credit_acc.id, debit=0, credit=amount),
    ])
    voucher.journal_entry_id = entry.id

    # ===== مرآة الخزينة (تغذي شاشة الخزينة ولوحة المعلومات) =====
    db.add(TreasuryEntry(
        type=TreasuryType.income if is_receipt else TreasuryType.expense,
        category=f"سند {kind.value}",
        description=f"{party_name}: {data.description}"[:240],
        amount=data.amount, entry_date=data.voucher_date, reference_no=voucher.voucher_no,
    ))

    log_action(db, user, "create", "voucher", resource_id=voucher.id,
               summary=f"إصدار سند {kind.value}: {voucher.voucher_no} - {party_name} ({data.amount} ﷼) بقيد {entry.entry_no}",
               ip_address=get_client_ip(request))
    db.commit()
    return _voucher_out(db, voucher)


@router.get("/{voucher_id}")
def get_voucher(voucher_id: str, db: Session = Depends(get_db),
                user: User = Depends(require_permission("vouchers"))):
    v = db.query(Voucher).filter(Voucher.id == voucher_id, Voucher.deleted == False).first()  # noqa: E712
    if not v:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "السند غير موجود")
    return _voucher_out(db, v)


@router.post("/{voucher_id}/void")
def void_voucher(voucher_id: str, request: Request, db: Session = Depends(get_db),
                 user: User = Depends(require_permission("vouchers"))):
    """إلغاء سند معتمد بقيد عكسي (القيد الأصلي يبقى موثقاً) + تعطيل مرآة الخزينة."""
    v = db.query(Voucher).filter(Voucher.id == voucher_id, Voucher.deleted == False).first()  # noqa: E712
    if not v:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "السند غير موجود")
    if v.status == "ملغي":
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "السند ملغي مسبقاً")
    treasury_acc = db.query(Account).filter(Account.id == v.treasury_account_id).first()
    counter_acc = db.query(Account).filter(Account.id == v.counter_account_id).first()
    if not treasury_acc or not counter_acc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "حسابات السند غير متوفرة لإلغائه")

    amount = Decimal(str(v.amount))
    is_receipt = v.kind == VoucherKind.receipt
    entry = JournalEntry(
        entry_no="TMP", entry_date=date.today(),
        description=f"قيد عكسي لإلغاء السند {v.voucher_no} — {v.party_name or ''}"[:250],
        entry_type=VOUCHER_ENTRY_TYPE[v.kind.value if isinstance(v.kind, VoucherKind) else str(v.kind)],
        reference=f"VOID-{v.voucher_no}", status="posted", created_by=user.id,
        member_id=v.member_id, donor_id=v.donor_id, beneficiary_id=v.beneficiary_id,
    )
    db.add(entry)
    db.flush()
    entry.entry_no = _next_entry_no(db)
    if is_receipt:  # عكس القيد: مدين الطرف المقابل / دائن الخزينة
        debit_acc, credit_acc = counter_acc, treasury_acc
    else:
        debit_acc, credit_acc = treasury_acc, counter_acc
    db.add_all([
        JournalLine(entry_id=entry.id, account_id=debit_acc.id, debit=amount, credit=0),
        JournalLine(entry_id=entry.id, account_id=credit_acc.id, debit=0, credit=amount),
    ])

    v.status = "ملغي"
    mirror = db.query(TreasuryEntry).filter(
        TreasuryEntry.reference_no == v.voucher_no, TreasuryEntry.deleted == False  # noqa: E712
    ).first()
    if mirror:
        mirror.deleted = True

    log_action(db, user, "update", "voucher", resource_id=v.id,
               summary=f"إلغاء السند {v.voucher_no} بقيد عكسي {entry.entry_no}",
               ip_address=get_client_ip(request))
    db.commit()
    return _voucher_out(db, v)


@router.get("/{voucher_id}/pdf")
def voucher_pdf(voucher_id: str, db: Session = Depends(get_db),
                user: User = Depends(require_permission("vouchers"))):
    """سند PDF رسمي جاهز للطباعة والتوقيع."""
    from app.models.fund_settings import FundSettings
    from app.services.export_service import generate_pdf_report

    v = db.query(Voucher).filter(Voucher.id == voucher_id, Voucher.deleted == False).first()  # noqa: E712
    if not v:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "السند غير موجود")

    kind = v.kind.value if isinstance(v.kind, VoucherKind) else str(v.kind)
    is_receipt = kind == RECEIPT
    party = v.member_name or v.party_name or ""
    entry = db.query(JournalEntry).filter(JournalEntry.id == v.journal_entry_id).first() if v.journal_entry_id else None
    fund = db.query(FundSettings).first()

    pdf = generate_pdf_report(
        title=f"سند {kind} - {v.voucher_no}",
        headers=["البيان", "القيمة"],
        rows=[
            ["رقم السند", v.voucher_no],
            [f"{'استلمنا من' if is_receipt else 'صرفنا إلى'}", party],
            ["وذلك مقابل", v.description],
            ["المبلغ", f"{v.amount:,} ريال"],
            ["طريقة الدفع", v.method],
            ["التاريخ", v.voucher_date],
            ["القيد المحاسبي المرتبط", entry.entry_no if entry else "-"],
            ["الحالة", v.status],
            [f"{'استلم بواسطة' if is_receipt else 'صرف بواسطة'}", v.issued_by_name],
            ["تاريخ الإصدار", date.today().isoformat()],
        ],
        fund_info={"name": fund.name if fund else "", "phone": getattr(fund, "phone", None), "email": getattr(fund, "email", None)},
    )
    log_action(db, user, "export", "voucher", resource_id=v.id, summary=f"تصدير سند PDF: {v.voucher_no}")
    db.commit()
    return Response(
        content=pdf, media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=voucher_{v.voucher_no}.pdf"},
    )
