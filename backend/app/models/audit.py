# app/models/audit.py
from sqlalchemy import Column, String, ForeignKey, Text, DateTime
from sqlalchemy import Uuid
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid

from app.core.database import Base
from app.models.mixins import Guid


class AuditLog(Base):
    """
    Immutable log of every create/update/delete/login action.
    Never updated or deleted once written - this is the compliance trail.
    """
    __tablename__ = "audit_logs"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    timestamp = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)

    user_id = Column(Guid, ForeignKey("users.id"), nullable=True)
    user_name = Column(String, nullable=True)

    action = Column(String, nullable=False)
    resource_type = Column(String, nullable=False)
    resource_id = Column(String, nullable=True)

    summary = Column(String, nullable=True)
    changes = Column(Text, nullable=True)

    ip_address = Column(String, nullable=True)
    device_id = Column(String, nullable=True)

    user = relationship("User", back_populates="audit_logs")
