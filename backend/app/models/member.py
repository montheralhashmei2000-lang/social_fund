# app/models/member.py
from sqlalchemy import Column, String, Integer, Enum
from sqlalchemy.types import TypeDecorator
import enum

from app.core.database import Base
from app.models.mixins import SyncMixin
from app.core.encryption import encrypt_field, decrypt_field, search_hash


class EncryptedString(TypeDecorator):
    """Transparently encrypts on write, decrypts on read. Column stays TEXT in the DB."""
    impl = String
    cache_ok = True

    def process_bind_param(self, value, dialect):
        return encrypt_field(value)

    def process_result_value(self, value, dialect):
        return decrypt_field(value)


class MemberStatus(str, enum.Enum):
    active = "نشط"
    suspended = "معلق"


class Member(Base, SyncMixin):
    __tablename__ = "members"

    name = Column(String, nullable=False, index=True)
    national_id = Column(EncryptedString(255), nullable=False)
    # هاش حتمي للبحث/فحص التكرار - القيمة الأصلية تبقى مشفرة فقط
    national_id_search = Column(String(64), index=True, nullable=True)
    phone = Column(EncryptedString(255), nullable=False)
    email = Column(EncryptedString(255), nullable=True)
    city = Column(String, nullable=True)
    join_date = Column(String, nullable=True)
    status = Column(
        Enum(MemberStatus, values_callable=lambda e: [m.value for m in e]),
        default=MemberStatus.active,
    )
    monthly_subscription = Column(Integer, default=0)
    total_paid = Column(Integer, default=0)
    balance_due = Column(Integer, default=0)
