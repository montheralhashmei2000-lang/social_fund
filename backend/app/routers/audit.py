# app/routers/audit.py
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User, RoleEnum
from app.models.audit import AuditLog

router = APIRouter(prefix="/audit-logs", tags=["Audit Log"])


class AuditLogOut(BaseModel):
    id: str
    timestamp: datetime
    user_name: Optional[str] = None
    action: str
    resource_type: str
    resource_id: Optional[str] = None
    summary: Optional[str] = None
    ip_address: Optional[str] = None

    class Config:
        from_attributes = True


@router.get("", response_model=List[AuditLogOut])
def list_audit_logs(
    resource_type: Optional[str] = None,
    action: Optional[str] = None,
    limit: int = Query(100, le=500),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if user.role != RoleEnum.admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "سجل العمليات متاح لمدير النظام فقط")

    q = db.query(AuditLog)
    if resource_type:
        q = q.filter(AuditLog.resource_type == resource_type)
    if action:
        q = q.filter(AuditLog.action == action)
    return q.order_by(AuditLog.timestamp.desc()).limit(limit).all()
