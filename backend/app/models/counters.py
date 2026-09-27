# app/models/counters.py
"""عدادات تسلسلية ذرّية لأرقام السندات والقيود — آمنة مع تزامن المستخدمين."""
from sqlalchemy import Column, Integer, String

from app.core.database import Base


class Counter(Base):
    __tablename__ = "counters"

    name = Column(String(60), primary_key=True)
    value = Column(Integer, nullable=False, default=0)
