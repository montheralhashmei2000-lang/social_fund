# app/models/welfare.py
"""
الوجه الخيري: المستفيدون (بمعزل عن الأعضاء المشتركين)، المساعدات الدورية،
المساعدات العينية والمخزون، وموازنات المصروفات.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, Integer, ForeignKey, String, Numeric, Date, DateTime, Text, UniqueConstraint

from app.core.database import Base
from app.models.mixins import Guid
from app.models.member import EncryptedString


class Beneficiary(Base):
    __tablename__ = "beneficiaries"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    full_name = Column(String(160), nullable=False, index=True)
    national_id = Column(EncryptedString(64), nullable=True)
    national_id_search = Column(String(64), index=True, nullable=True)
    phone = Column(EncryptedString(64), nullable=True)
    family_size = Column(Integer, default=1)
    monthly_income = Column(Numeric(14, 2), default=0)
    housing = Column(String(40), nullable=True)
    case_summary = Column(Text, nullable=True)
    status = Column(String(12), default="active", index=True)
    registered_by = Column(Guid, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class PeriodicAid(Base):
    """مساعدة دورية (معاش): تستحق شهرياً حتى تعليقها."""
    __tablename__ = "periodic_aids"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    beneficiary_id = Column(Guid, ForeignKey("beneficiaries.id"), nullable=False, index=True)
    monthly_amount = Column(Numeric(14, 2), nullable=False)
    started_on = Column(Date, nullable=False)
    status = Column(String(12), default="active", index=True)
    last_paid_period = Column(String(7), nullable=True)  # YYYY-MM
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class InKindItem(Base):
    """بند مخزون عيني: سلة غذائية، أثاث، ألبسة..."""
    __tablename__ = "in_kind_items"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    name = Column(String(140), nullable=False, index=True)
    unit = Column(String(30), default="قطعة")
    quantity = Column(Numeric(14, 2), default=0)
    reorder_level = Column(Numeric(14, 2), default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class InKindMovement(Base):
    __tablename__ = "in_kind_movements"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    item_id = Column(Guid, ForeignKey("in_kind_items.id"), nullable=False, index=True)
    direction = Column(String(6), nullable=False)  # in / out
    quantity = Column(Numeric(14, 2), nullable=False)
    movement_date = Column(Date, nullable=False)
    beneficiary_id = Column(Guid, nullable=True, index=True)
    aid_id = Column(Guid, nullable=True, index=True)
    campaign_id = Column(Guid, nullable=True, index=True)
    note = Column(String(255), nullable=True)
    by_user_id = Column(Guid, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class Budget(Base):
    """موازنة شهرية لبند مصروف (حساب من شجرة الحسابات)."""
    __tablename__ = "budgets"
    __table_args__ = (UniqueConstraint("period", "account_id", name="uq_budget_period_account"),)

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    period = Column(String(7), nullable=False, index=True)
    account_id = Column(Guid, ForeignKey("accounts.id"), nullable=False, index=True)
    planned_amount = Column(Numeric(14, 2), nullable=False)
    created_by = Column(Guid, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
