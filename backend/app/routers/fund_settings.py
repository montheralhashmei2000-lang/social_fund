# app/routers/fund_settings.py
import os
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Request, status
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

def _save_media(data: bytes, ext: str) -> str:
    """يحفظ ملف وسائط ويعيد اسمه - يُخدم من /media بدل تخزين القاعدة."""
    media = Path(os.environ.get("MEDIA_DIR", "./media"))
    media.mkdir(parents=True, exist_ok=True)
    name = f"{uuid.uuid4().hex}.{ext}"
    (media / name).write_bytes(data)
    return name


@router.put("/logo-file")
async def upload_logo_file(request: Request, db: Session = Depends(get_db),
                           user: User = Depends(require_permission("settings"))):
    """رفع شعار كملف (multipart/form-data: file) - يُخزن على القرص ويُخدم من /media."""
    content_type = request.headers.get("content-type", "")
    if "multipart/form-data" not in content_type:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "أرسل الشعار كـ multipart/form-data")
    form = await request.form()
    f = form.get("file")
    if f is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "الملف مفقود")
    ext = (os.path.splitext(f.filename or "")[1] or ".png").lstrip(".").lower()
    if ext not in ("png", "jpg", "jpeg", "webp"):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة غير مدعومة (png/jpg/webp) — SVG مرفوض لأنه قد يحمل سكربتات")
    data = await f.read()
    if len(data) > 5 * 1024 * 1024:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "أقصى حجم 5 ميغابايت")
    name = _save_media(data, ext)
    fs = db.query(FundSettings).first()
    if not fs:
        fs = FundSettings(name="الصندوق الاجتماعي التنموي")
        db.add(fs)
    fs.logo_base64 = f"/media/{name}"  # توافق: الواجهة تقرأ الرابط من نفس الحقل
    db.commit()
    return {"logo_url": f"/media/{name}"}
