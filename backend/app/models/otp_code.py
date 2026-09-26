# app/models/otp_code.py
"""
يخزّن رموز OTP في قاعدة البيانات بدل متغيّر Python بالذاكرة.

لماذا هذا أفضل من التخزين بالذاكرة (الأسلوب القديم في otp_service.py):
  - يبقى الرمز صالحاً حتى لو أعاد الخادم نفسه التشغيل (نشر تحديث، إلخ)
  - يعمل بشكل صحيح حتى لو شغّلت أكثر من نسخة خادم خلف موازن أحمال
    (Load Balancer)، لأن كل النسخ تقرأ/تكتب من نفس قاعدة البيانات
    بدل الاحتفاظ كل واحدة بحالتها الخاصة

هذا الجدول ليس من الجداول القابلة للمزامنة (لا SyncMixin) لأنه بيانات
مؤقتة بحتة على الخادم فقط، لا علاقة له بمزامنة التطبيق بين الأجهزة.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, DateTime, Boolean
from sqlalchemy import Uuid

from app.core.database import Base
from app.models.mixins import Guid


class OtpCode(Base):
    __tablename__ = "otp_codes"

    id = Column(Guid, primary_key=True, default=uuid.uuid4)
    token = Column(String, unique=True, nullable=False, index=True)
    user_id = Column(Guid, nullable=False, index=True)
    code = Column(String, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    consumed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
