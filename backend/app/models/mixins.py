# app/models/mixins.py
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Boolean, String, TypeDecorator, Uuid
from sqlalchemy import Uuid




class Guid(TypeDecorator):
    """UUID متوافق مع كل المحركات (PostgreSQL/SQLite): يقبل str أو UUID ويعيد str دائماً."""
    impl = Uuid
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is None or value == "":
            return value
        if isinstance(value, str):
            return uuid.UUID(value)
        return value

    def process_result_value(self, value, dialect):
        return None if value is None else str(value)


class SyncMixin:
    """
    Every syncable table gets:
    - id: UUID (safe to generate offline on the device, no collision risk)
    - updated_at: used for "last write wins" conflict resolution
    - deleted: soft-delete flag so deletions can propagate during sync
    - device_id: which device last wrote this row (useful for debugging conflicts)
    """
    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        index=True,
    )
    deleted = Column(Boolean, default=False, index=True)
    device_id = Column(String, nullable=True)
