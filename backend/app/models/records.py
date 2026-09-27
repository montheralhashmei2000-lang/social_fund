# app/models/records.py
from sqlalchemy import Column, String, Integer, Enum, ForeignKey, Text, Boolean
from sqlalchemy import Uuid
import enum

from app.core.database import Base
from app.models.mixins import Guid, SyncMixin


class AidStatus(str, enum.Enum):
    pending = "قيد المراجعة"
    approved = "معتمدة"
    disbursed = "مصروفة"
    rejected = "مرفوضة"


class AidRequest(Base, SyncMixin):
    __tablename__ = "aid_requests"

    member_id = Column(Guid, ForeignKey("members.id"), nullable=False, index=True)
    member_name = Column(String, nullable=False)
    aid_type = Column(String, nullable=False)
    amount = Column(Integer, nullable=False)
    request_date = Column(String, nullable=False)
    # values_callable: بدونها SQLAlchemy يخزّن اسم العضو الإنجليزي (pending) بدل
    # قيمته العربية (قيد المراجعة) - يعمل صدفة على SQLite لكنه يفشل على نوع
    # PostgreSQL ENUM الذي أنشأته الهجرة بالقيم العربية فقط.
    status = Column(
        Enum(AidStatus, values_callable=lambda e: [m.value for m in e]),
        default=AidStatus.pending,
    )
    note = Column(Text, nullable=True)
    reviewer_name = Column(String, nullable=True)
    reviewer_id = Column(Guid, ForeignKey("users.id"), nullable=True)


    # maker-checker: صانع الطلب لا يعتمده بنفسه + ربط اختياري بمستفيد خيري
    created_by = Column(Guid, nullable=True, index=True)
    beneficiary_id = Column(Guid, nullable=True, index=True)

class Subscription(Base, SyncMixin):
    __tablename__ = "subscriptions"

    member_id = Column(Guid, ForeignKey("members.id"), nullable=False, index=True)
    member_name = Column(String, nullable=False)
    amount = Column(Integer, nullable=False)
    payment_date = Column(String, nullable=False)
    method = Column(String, nullable=False)
    reference_no = Column(String, nullable=True)


class TreasuryType(str, enum.Enum):
    income = "إيراد"
    expense = "مصروف"


class TreasuryEntry(Base, SyncMixin):
    __tablename__ = "treasury_entries"

    type = Column(Enum(TreasuryType, values_callable=lambda e: [m.value for m in e]), nullable=False)
    category = Column(String, nullable=False)
    description = Column(String, nullable=False)
    amount = Column(Integer, nullable=False)
    entry_date = Column(String, nullable=False)
    reference_no = Column(String, nullable=True)


class VoucherKind(str, enum.Enum):
    receipt = "قبض"
    payment = "صرف"


class Voucher(Base, SyncMixin):
    __tablename__ = "vouchers"

    voucher_no = Column(String, unique=True, nullable=False, index=True)
    kind = Column(Enum(VoucherKind, values_callable=lambda e: [m.value for m in e]), nullable=False)
    # الطرف: عضو / مانح / مستفيد / جهة حرة (واحد على الأقل)
    member_id = Column(Guid, ForeignKey("members.id"), nullable=True, index=True)
    member_name = Column(String, nullable=True)
    donor_id = Column(Guid, nullable=True, index=True)
    beneficiary_id = Column(Guid, nullable=True, index=True)
    party_name = Column(String, nullable=True)
    amount = Column(Integer, nullable=False)
    voucher_date = Column(String, nullable=False)
    method = Column(String, nullable=False)
    description = Column(String, nullable=False)
    issued_by_name = Column(String, nullable=False)
    issued_by_id = Column(Guid, ForeignKey("users.id"), nullable=True)
    status = Column(String, default="معتمد")
    # الربط بالبنية المحاسبية (القيد المزدوج)
    treasury_account_id = Column(Guid, nullable=True, index=True)
    counter_account_id = Column(Guid, nullable=True, index=True)
    journal_entry_id = Column(Guid, nullable=True, index=True)


class Message(Base, SyncMixin):
    __tablename__ = "messages"

    from_user_id = Column(Guid, ForeignKey("users.id"), nullable=False)
    from_name = Column(String, nullable=False)
    to_user_id = Column(Guid, ForeignKey("users.id"), nullable=False)
    to_name = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    read = Column(Boolean, default=False)


class Event(Base, SyncMixin):
    __tablename__ = "events"

    title = Column(String, nullable=False)
    event_date = Column(String, nullable=False)
    event_time = Column(String, nullable=True)
    place = Column(String, nullable=True)
    type = Column(String, nullable=True)
    color = Column(String, default="#1B5E20")
