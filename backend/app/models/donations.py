# app/models/donations.py
"""المانحون: تجار ومؤسسات وأفراد محسنون — مع الوعود والمستويات."""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, Integer, ForeignKey, String, Numeric, Date, DateTime, Boolean, Text

from app.core.database import Base
from app.models.mixins import Guid
from app.models.member import EncryptedString

DONOR_TYPES = {"merchant": "تاجر", "organization": "مؤسسة", "individual": "فرد محسن", "philanthropist": "واعظ خير"}
DONOR_TIERS = {"bronze": "برونزي", "silver": "فضي", "gold": "ذهبي", "platinum": "بلاتيني"}
PLEDGE_FREQUENCIES = {"monthly": "شهري", "quarterly": "ربع سنوي", "annual": "سنوي", "one_time": "مرة واحدة"}


class Donor(Base):
    __tablename__ = "donors"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    name = Column(String(160), nullable=False, index=True)
    donor_type = Column(String(20), default="individual", nullable=False)
    tier = Column(String(20), default="silver", index=True)
    phone = Column(EncryptedString(64), nullable=True)
    email = Column(EncryptedString(255), nullable=True)
    notes = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class Pledge(Base):
    __tablename__ = "pledges"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    donor_id = Column(Guid, ForeignKey("donors.id"), nullable=False, index=True)
    amount = Column(Numeric(14, 2), nullable=False)
    frequency = Column(String(20), default="monthly", nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    status = Column(String(12), default="active", index=True)
    last_fulfilled_on = Column(Date, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class Campaign(Base):
    __tablename__ = "campaigns"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    name = Column(String(160), nullable=False, index=True)
    description = Column(Text, nullable=True)
    goal_amount = Column(Numeric(14, 2), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    status = Column(String(12), default="active", index=True)
    created_by = Column(Guid, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
