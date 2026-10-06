# app/routers/accounts.py
"""شجرة الحسابات: البنوك والمحافظ والصناديق النقدية + المحولات + المطابقة البنكية."""
from datetime import date, datetime, timezone
from decimal import Decimal
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Response
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission, get_current_user
from app.models.user import User
from app.models.accounting import Account, JournalEntry, JournalLine, BankStatementLine, ACCOUNT_TYPES
from app.services.audit_service import log_action

router = APIRouter(prefix="/accounts", tags=["Accounts & Banking"])

DEBIT_NATURAL = {"asset", "expense"}


class AccountIn(BaseModel):
    code: str
    name: str
    type: str
    is_bank: bool = False
    is_cash: bool = False
    is_wallet: bool = False
    bank_name: Optional[str] = None
    account_number: Optional[str] = None
    currency: str = "YER"


class TransferIn(BaseModel):
    from_account_id: str
    to_account_id: str
    amount: float
    description: str
    entry_date: str  # YYYY-MM-DD


class StatementLineIn(BaseModel):
    line_date: str
    description: str
    amount: float  # موجب = وارد، سالب = صادر
    external_ref: Optional[str] = None


class MatchIn(BaseModel):
    journal_line_id: str


def _account_balance(db: Session, account: Account, date_from=None, date_to=None) -> Decimal:
    q = db.query(
        func.coalesce(func.sum(JournalLine.debit), 0),
        func.coalesce(func.sum(JournalLine.credit), 0),
    ).join(JournalEntry, JournalLine.entry_id == JournalEntry.id).filter(
        JournalLine.account_id == account.id,
        JournalEntry.status == "posted",
    )
    if date_from:
        q = q.filter(JournalEntry.entry_date >= date_from)
    if date_to:
        q = q.filter(JournalEntry.entry_date <= date_to)
    debit, credit = q.one()
    debit, credit = Decimal(str(debit)), Decimal(str(credit))
    return (debit - credit) if account.type in DEBIT_NATURAL else (credit - debit)


def _account_out(a: Account, balance: Decimal):
    return {
        "id": str(a.id), "code": a.code, "name": a.name, "type": a.type,
        "type_label": ACCOUNT_TYPES.get(a.type, a.type),
        "is_bank": a.is_bank, "is_cash": a.is_cash, "is_wallet": a.is_wallet,
        "bank_name": a.bank_name, "account_number": a.account_number,
        "currency": a.currency, "is_active": a.is_active,
        "balance": float(balance),
    }


@router.get("")
def list_accounts(db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    out = []
    for a in db.query(Account).order_by(Account.code).all():
        out.append(_account_out(a, _account_balance(db, a)))
    return out


@router.post("", status_code=status.HTTP_201_CREATED)
def create_account(payload: AccountIn, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    if payload.type not in ACCOUNT_TYPES:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "نوع الحساب غير صالح")
    if db.query(Account).filter(Account.code == payload.code).first():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "رمز الحساب مستخدم مسبقاً")
    a = Account(**payload.model_dump())
    db.add(a)
    db.flush()
    log_action(db, user, "create", "account", resource_id=a.id, summary=f"إنشاء حساب: {a.code} {a.name}")
    db.commit()
    return _account_out(a, Decimal(0))


@router.post("/seed-defaults")
def seed_defaults(db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    from app.services.accounting_seed import ensure_default_accounts
    created = ensure_default_accounts(db)
    return {"seeded": created}


@router.post("/transfer")
def transfer(payload: TransferIn, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    """تحويل داخلي بين حسابين: قيد متوازن من سطرين — لا يُسجَّل كإيراد أو مصروف."""
    amount = Decimal(str(payload.amount))
    if amount <= 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ يجب أن يكون أكبر من صفر")
    if payload.from_account_id == payload.to_account_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "لا يمكن التحويل إلى نفس الحساب")

    src = db.query(Account).filter(Account.id == payload.from_account_id).first()
    dst = db.query(Account).filter(Account.id == payload.to_account_id).first()
    if not src or not dst:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "أحد الحسابين غير موجود")

    try:
        entry_date = date.fromisoformat(payload.entry_date)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة التاريخ غير صحيحة (YYYY-MM-DD)")

    entry = JournalEntry(
        entry_no="TMP", entry_date=entry_date,
        description=payload.description or f"تحويل من {src.name} إلى {dst.name}",
        entry_type="transfer", status="posted", created_by=user.id,
    )
    db.add(entry)
    db.flush()
    from app.services.sequence_service import next_entry_no
    entry.entry_no = next_entry_no(db)
    db.add_all([
        JournalLine(entry_id=entry.id, account_id=dst.id, debit=amount, credit=0,
                    memo=f"تحويل وارد من {src.name}"),
        JournalLine(entry_id=entry.id, account_id=src.id, debit=0, credit=amount,
                    memo=f"تحويل صادر إلى {dst.name}"),
    ])
    log_action(db, user, "create", "journal_entry", resource_id=entry.id,
               summary=f"تحويل داخلي {amount} من {src.name} إلى {dst.name}")
    db.commit()
    return {"message": "تم التحويل", "entry_no": entry.entry_no}


# ================= المطابقة البنكية =================

@router.get("/{account_id}/reconciliation")
def reconciliation(account_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    account = db.query(Account).filter(Account.id == account_id).first()
    if not account:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحساب غير موجود")

    lines = db.query(BankStatementLine).filter(
        BankStatementLine.account_id == account.id
    ).order_by(BankStatementLine.line_date.desc()).all()

    ledger_balance = _account_balance(db, account)
    statement_sum = sum(Decimal(str(l.amount)) for l in lines)

    return {
        "account": _account_out(account, ledger_balance),
        "ledger_balance": float(ledger_balance),
        "statement_sum": float(statement_sum),
        "difference": float(ledger_balance - statement_sum),
        "lines": [
            {
                "id": str(l.id), "line_date": l.line_date.isoformat(),
                "description": l.description, "amount": float(l.amount),
                "external_ref": l.external_ref,
                "matched_line_id": str(l.matched_line_id) if l.matched_line_id else None,
            }
            for l in lines
        ],
    }


@router.get("/{account_id}/unmatched-journal-lines")
def unmatched_journal_lines(account_id: str, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    """سطور القيود الخاصة بهذا الحساب التي لم تطابقها كشوف بعد."""
    rows = (
        db.query(JournalLine, JournalEntry)
        .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
        .outerjoin(BankStatementLine, BankStatementLine.matched_line_id == JournalLine.id)
        .filter(
            JournalLine.account_id == account_id,
            JournalEntry.status == "posted",
            BankStatementLine.id.is_(None),
        )
        .order_by(JournalEntry.entry_date.desc())
        .limit(200)
        .all()
    )
    return [
        {
            "journal_line_id": str(line.id),
            "entry_no": entry.entry_no,
            "entry_date": entry.entry_date.isoformat(),
            "description": entry.description,
            "debit": float(line.debit), "credit": float(line.credit),
        }
        for line, entry in rows
    ]


@router.post("/{account_id}/statement-lines", status_code=status.HTTP_201_CREATED)
def add_statement_line(account_id: str, payload: StatementLineIn, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    account = db.query(Account).filter(Account.id == account_id).first()
    if not account:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحساب غير موجود")
    try:
        d = date.fromisoformat(payload.line_date)
    except ValueError:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة التاريخ غير صحيحة")
    if payload.amount == 0:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "المبلغ لا يمكن أن يكون صفراً")
    line = BankStatementLine(
        account_id=account.id, line_date=d, description=payload.description,
        amount=Decimal(str(payload.amount)), external_ref=payload.external_ref, created_by=user.id,
    )
    db.add(line)
    log_action(db, user, "create", "statement_line", resource_id=account.id,
               summary=f"سطر كشف حساب جديد على {account.name}: {payload.amount}")
    db.commit()
    return {"message": "تمت إضافة سطر الكشف"}


@router.post("/{account_id}/statement-lines/{line_id}/match")
def match_statement_line(account_id: str, line_id: str, payload: MatchIn, db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):
    line = db.query(BankStatementLine).filter(
        BankStatementLine.id == line_id, BankStatementLine.account_id == account_id
    ).first()
    if not line:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "سطر الكشف غير موجود")
    jl = db.query(JournalLine).filter(JournalLine.id == payload.journal_line_id).first()
    if not jl:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "سطر القيد غير موجود")
    line.matched_line_id = jl.id
    db.commit()
    return {"message": "تمت المطابقة"}
