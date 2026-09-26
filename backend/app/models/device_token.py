# app/models/device_token.py
"""
Stores Firebase Cloud Messaging tokens so the backend can push notifications
to specific devices. Not a SyncMixin table - tokens are server-side only,
never edited by the offline sync engine, and don't need soft-delete history.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, ForeignKey, DateTime
from sqlalchemy import Uuid

from app.core.database import Base
from app.models.mixins import Guid


class DeviceToken(Base):
    __tablename__ = "device_tokens"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Guid, ForeignKey("users.id"), nullable=False, index=True)
    token = Column(String, nullable=False, unique=True, index=True)
    platform = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    last_used_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
