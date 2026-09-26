# app/models/user.py
from sqlalchemy import Column, String, Boolean, Enum
from sqlalchemy.orm import relationship
import enum

from app.core.database import Base
from app.models.mixins import SyncMixin


class RoleEnum(str, enum.Enum):
    admin = "admin"
    accountant = "accountant"
    reviewer = "reviewer"
    viewer = "viewer"


class User(Base, SyncMixin):
    __tablename__ = "users"

    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    role = Column(Enum(RoleEnum), default=RoleEnum.viewer, nullable=False)
    avatar_initial = Column(String(2), default="?")
    is_active = Column(Boolean, default=True)
    phone = Column(String, nullable=True)

    otp_enabled = Column(Boolean, default=True)
    biometric_enabled = Column(Boolean, default=False)

    audit_logs = relationship("AuditLog", back_populates="user")


ROLE_PERMISSIONS = {
    "admin": {
        "members", "subscriptions", "aids", "treasury", "vouchers", "messages",
        "scheduler", "reports", "settings", "users",
        "accounting", "donors", "campaigns", "beneficiaries", "inkind", "budgets",
    },
    "accountant": {
        "members", "subscriptions", "treasury", "vouchers", "reports",
        "accounting", "donors", "campaigns", "budgets", "inkind",
    },
    "reviewer": {"members", "aids", "reports", "beneficiaries"},
    "viewer": {"reports"},
}


def has_permission(role, resource):
    return resource in ROLE_PERMISSIONS.get(role, set())
