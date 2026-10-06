# app/schemas/domain.py
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class SyncFieldsOut(BaseModel):
    id: str
    updated_at: datetime
    deleted: bool = False
    model_config = ConfigDict(from_attributes=True)


class MemberBase(BaseModel):
    name: str
    national_id: str
    phone: str
    email: Optional[str] = None
    city: Optional[str] = None
    join_date: Optional[str] = None
    monthly_subscription: int = 0


class MemberCreate(MemberBase):
    pass


class MemberUpdate(BaseModel):
    name: Optional[str] = None
    national_id: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    city: Optional[str] = None
    join_date: Optional[str] = None
    monthly_subscription: Optional[int] = None
    status: Optional[str] = None


class MemberOut(MemberBase, SyncFieldsOut):
    status: str
    total_paid: int
    balance_due: int


class AidCreate(BaseModel):
    beneficiary_id: Optional[str] = None
    member_id: str
    aid_type: str
    amount: int = Field(gt=0)
    request_date: str
    note: Optional[str] = None


class AidStatusUpdate(BaseModel):
    status: str


class AidOut(SyncFieldsOut):
    member_id: str
    member_name: str
    aid_type: str
    amount: int
    request_date: str
    status: str
    note: Optional[str] = None
    reviewer_name: Optional[str] = None


class SubscriptionCreate(BaseModel):
    member_id: str
    amount: int
    payment_date: str
    method: str


class SubscriptionOut(SyncFieldsOut):
    member_id: str
    member_name: str
    amount: int
    payment_date: str
    method: str
    reference_no: Optional[str] = None


class TreasuryCreate(BaseModel):
    type: str
    category: str
    description: str
    amount: int = Field(gt=0)
    entry_date: str


class TreasuryOut(SyncFieldsOut):
    type: str
    category: str
    description: str
    amount: int
    entry_date: str
    reference_no: Optional[str] = None


class VoucherCreate(BaseModel):
    kind: str
    amount: int
    voucher_date: str
    method: str
    description: str
    member_id: Optional[str] = None
    donor_id: Optional[str] = None
    beneficiary_id: Optional[str] = None
    party_name: Optional[str] = None
    treasury_account_id: str
    counter_account_id: str


class VoucherOut(SyncFieldsOut):
    voucher_no: str
    kind: str
    member_id: Optional[str] = None
    member_name: str = ""
    donor_id: Optional[str] = None
    beneficiary_id: Optional[str] = None
    party_name: Optional[str] = None
    amount: int
    voucher_date: str
    method: str
    description: str
    issued_by_name: str
    status: str
    treasury_account_id: Optional[str] = None
    counter_account_id: Optional[str] = None
    journal_entry_id: Optional[str] = None
    journal_entry_no: Optional[str] = None


class MessageCreate(BaseModel):
    to_user_id: str
    body: str


class MessageOut(SyncFieldsOut):
    from_user_id: str
    from_name: str
    to_user_id: str
    to_name: str
    body: str
    read: bool


class EventCreate(BaseModel):
    title: str
    event_date: str
    event_time: Optional[str] = None
    place: Optional[str] = None
    type: Optional[str] = None
    color: Optional[str] = "#1B5E20"


class EventOut(SyncFieldsOut):
    title: str
    event_date: str
    event_time: Optional[str] = None
    place: Optional[str] = None
    type: Optional[str] = None
    color: str


class FundSettingsUpdate(BaseModel):
    name: Optional[str] = None
    logo_base64: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    registration_no: Optional[str] = None


class FundSettingsOut(SyncFieldsOut):
    name: str
    logo_base64: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    registration_no: Optional[str] = None
