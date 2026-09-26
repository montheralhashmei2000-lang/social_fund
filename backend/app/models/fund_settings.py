# app/models/fund_settings.py
from sqlalchemy import Column, String, Text

from app.core.database import Base
from app.models.mixins import SyncMixin


class FundSettings(Base, SyncMixin):
    """
    Single-row table holding organization-level info shown on vouchers/reports:
    name, logo, contact details. The API always upserts the one row with a
    fixed well-known id rather than allowing multiple rows.
    """
    __tablename__ = "fund_settings"

    name = Column(String, nullable=False, default="الصندوق الاجتماعي التنموي")
    logo_base64 = Column(Text, nullable=True)
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)
    address = Column(String, nullable=True)
    registration_no = Column(String, nullable=True)
