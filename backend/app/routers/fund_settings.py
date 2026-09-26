# app/routers/fund_settings.py
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission, get_client_ip
from app.models.fund_settings import FundSettings
from app.models.user import User
from app.schemas.domain import FundSettingsUpdate, FundSettingsOut
from app.services.audit_service import log_action

router = APIRouter(prefix="/fund-settings", tags=["Fund Settings"])


def get_or_create_settings(db: Session) -> FundSettings:
    row = db.query(FundSettings).first()
    if not row:
        row = FundSettings(name="الصندوق الاجتماعي التنموي")
        db.add(row)
        db.commit()
        db.refresh(row)
    return row


@router.get("", response_model=FundSettingsOut)
def get_fund_settings(db: Session = Depends(get_db), user: User = Depends(require_permission("settings"))):
    return get_or_create_settings(db)


@router.put("", response_model=FundSettingsOut)
def update_fund_settings(payload: FundSettingsUpdate, request: Request, db: Session = Depends(get_db),
                          user: User = Depends(require_permission("settings"))):
    row = get_or_create_settings(db)
    updates = payload.model_dump(exclude_unset=True)
    for field, val in updates.items():
        setattr(row, field, val)

    log_action(db, user, "update", "fund_settings", resource_id=row.id,
               summary="تحديث بيانات الصندوق", changes=updates, ip_address=get_client_ip(request))
    db.commit()
    db.refresh(row)
    return row
