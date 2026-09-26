# app/models/accounting.py
"""
النواة المحاسبية: شجرة الحسابات، القيد المزدوج، سطور كشف الحساب البنكي.

المبالغ Numeric(14,2) (قرار صريح: عملة عشرية للدقة البنكية).
كل حركة مالية تُسجَّل قيداً متوازناً (مدين = دائن) — القيد المُرحَّل لا يُعدل ولا يُحذف.
"""
import uuid
from datetime import date, datetime, timezone

from sqlalchemy import Column, String, Numeric, Date, DateTime, Boolean, ForeignKey, Text, UniqueConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.mixins import Guid

ACCOUNT_TYPES = {
    "asset": "أصول",
    "liability": "خصوم",
    "equity": "حقوق ملكية",
    "income": "إيرادات",
    "expense": "مصروفات",
}

# أنواع القيود المدعومة
ENTRY_TYPES = {
    "subscription": "تحصيل اشتراك",
    "donation": "تبرع",
    "campaign_donation": "تبرع حملة",
    "aid_disbursement": "صرف مساعدة",
    "expense": "مصروف",
    "transfer": "تحويل بين حسابات",
    "adjustment": "تسوية",
    "periodic_aid": "مساعدة دورية",
    "voucher_receipt": "سند قبض",
    "voucher_payment": "سند صرف",
}


class Account(Base):
    __tablename__ = "accounts"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    code = Column(String(20), unique=True, index=True, nullable=False)
    name = Column(String(120), nullable=False)
    type = Column(String(20), nullable=False, index=True)  # مفتاح من ACCOUNT_TYPES
    is_bank = Column(Boolean, default=False, index=True)
    is_cash = Column(Boolean, default=False)
    is_wallet = Column(Boolean, default=False)
    bank_name = Column(String(120), nullable=True)
    account_number = Column(String(60), nullable=True)
    currency = Column(String(8), default="YER")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class JournalEntry(Base):
    __tablename__ = "journal_entries"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    entry_no = Column(String(20), unique=True, index=True)  # JE-000123
    entry_date = Column(Date, nullable=False, index=True)
    description = Column(String(255), nullable=False)
    entry_type = Column(String(30), nullable=False, index=True)
    reference = Column(String(60), nullable=True)
    status = Column(String(12), default="posted", index=True)  # posted / draft / void
    # ارتباطات اختيارية بتقارير الحملات والمانحين والمساعدات
    campaign_id = Column(Guid, ForeignKey("campaigns.id"), nullable=True, index=True)
    donor_id = Column(Guid, ForeignKey("donors.id"), nullable=True, index=True)
    member_id = Column(Guid, nullable=True, index=True)
    aid_id = Column(Guid, nullable=True, index=True)
    beneficiary_id = Column(Guid, nullable=True, index=True)
    voucher_id = Column(Guid, nullable=True, index=True)
    created_by = Column(Guid, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    lines = relationship("JournalLine", cascade="all, delete-orphan", backref="entry")


class JournalLine(Base):
    __tablename__ = "journal_lines"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    entry_id = Column(Guid, ForeignKey("journal_entries.id"), nullable=False, index=True)
    account_id = Column(Guid, ForeignKey("accounts.id"), nullable=False, index=True)
    debit = Column(Numeric(14, 2), default=0, nullable=False)
    credit = Column(Numeric(14, 2), default=0, nullable=False)
    memo = Column(String(255), nullable=True)

    account = relationship("Account")


class BankStatementLine(Base):
    __tablename__ = "bank_statement_lines"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    account_id = Column(Guid, ForeignKey("accounts.id"), nullable=False, index=True)
    line_date = Column(Date, nullable=False)
    description = Column(String(255), nullable=False)
    amount = Column(Numeric(14, 2), nullable=False)  # موجب = وارد للبنك، سالب = صادر
    external_ref = Column(String(60), nullable=True)
    matched_line_id = Column(Guid, ForeignKey("journal_lines.id"), nullable=True, index=True)
    created_by = Column(Guid, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
