# app/models/refresh_session.py
"""
جلسات refresh tokens المخزّنة على الخادم (مجزّأة SHA-256).

لماذا هذا الجدول (معالجة ملاحظة الفحص 21):
  - يسمح بإلغاء جلسة واحدة أو كل جلسات المستخدم (logout / logout-all /
    تغيير كلمة المرور) بدلاً من بقاء token مسروق صالحاً حتى انتهاء مدته.
  - يتيح تدوير الـrefresh token عند كل استخدام (rotation) فتفقد أي نسخة
    مسروقة قيمتها بعد أول تحديث.

هذا الجدول ليس من جداول المزامنة (لا SyncMixin) - بيانات خادم فقط.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, ForeignKey, DateTime, Boolean
from sqlalchemy import Uuid

from app.core.database import Base
from app.models.mixins import Guid


class RefreshSession(Base):
    __tablename__ = "refresh_sessions"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Guid, ForeignKey("users.id"), nullable=False, index=True)
    token_hash = Column(String(64), unique=True, nullable=False, index=True)
    device_id = Column(String, nullable=True)
    ip_address = Column(String, nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    revoked = Column(Boolean, default=False, index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
