# app/routers/backup.py
"""
Backup/restore via pg_dump and pg_restore subprocess calls.

REQUIREMENTS: the pg_dump and pg_restore binaries (from the postgresql-client
package) must be installed and on PATH in whatever environment runs the API
server. This is standard on most Linux distros via `apt install postgresql-client`.

SECURITY: restore is destructive and admin-only. It's wrapped in a
confirmation flag in the request to avoid accidental calls, but there's no
undo beyond taking another backup first.
"""
import subprocess
import tempfile
import os
from datetime import datetime
from urllib.parse import urlparse

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.deps import require_permission
from app.models.user import User, RoleEnum
from app.services.audit_service import log_action

router = APIRouter(prefix="/backup", tags=["Backup & Restore"])


def _parse_db_url():
    u = urlparse(settings.DATABASE_URL)
    return {
        "host": u.hostname or "localhost",
        "port": str(u.port or 5432),
        "user": u.username,
        "password": u.password,
        "dbname": u.path.lstrip("/"),
    }


def require_admin(user: User = Depends(require_permission("settings"))) -> User:
    if user.role != RoleEnum.admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "النسخ الاحتياطي والاستعادة متاحة لمدير النظام فقط")
    return user


@router.post("/create")
def create_backup(db: Session = Depends(get_db), user: User = Depends(require_admin)):
    conn = _parse_db_url()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = os.path.join(tempfile.gettempdir(), f"social_fund_backup_{timestamp}.sql")

    env = os.environ.copy()
    if conn["password"]:
        env["PGPASSWORD"] = conn["password"]

    cmd = [
        "pg_dump", "-h", conn["host"], "-p", conn["port"], "-U", conn["user"],
        "-F", "c", "-f", out_path, conn["dbname"],
    ]

    try:
        subprocess.run(cmd, env=env, check=True, capture_output=True, timeout=300)
    except FileNotFoundError:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            "أداة pg_dump غير مثبتة على الخادم. ثبّت حزمة postgresql-client.",
        )
    except subprocess.CalledProcessError as e:
        raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, f"فشل إنشاء النسخة الاحتياطية: {e.stderr.decode(errors='ignore')}")

    log_action(db, user, "export", "backup", summary=f"إنشاء نسخة احتياطية: {os.path.basename(out_path)}")
    db.commit()

    return FileResponse(out_path, filename=os.path.basename(out_path), media_type="application/octet-stream")


@router.post("/restore")
async def restore_backup(
    confirm: bool = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user: User = Depends(require_admin),
):
    if not confirm:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "يجب تأكيد عملية الاستعادة (confirm=true)")

    conn = _parse_db_url()
    env = os.environ.copy()
    if conn["password"]:
        env["PGPASSWORD"] = conn["password"]

    tmp_path = os.path.join(tempfile.gettempdir(), f"restore_upload_{datetime.now().strftime('%Y%m%d_%H%M%S')}.dump")
    with open(tmp_path, "wb") as f:
        f.write(await file.read())

    cmd = [
        "pg_restore", "-h", conn["host"], "-p", conn["port"], "-U", conn["user"],
        "-d", conn["dbname"], "--clean", "--if-exists", tmp_path,
    ]

    try:
        subprocess.run(cmd, env=env, check=True, capture_output=True, timeout=600)
    except FileNotFoundError:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            "أداة pg_restore غير مثبتة على الخادم. ثبّت حزمة postgresql-client.",
        )
    except subprocess.CalledProcessError as e:
        raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, f"فشلت عملية الاستعادة: {e.stderr.decode(errors='ignore')}")
    finally:
        os.remove(tmp_path)

    log_action(db, user, "restore", "backup", summary=f"استعادة نسخة احتياطية من ملف: {file.filename}")
    db.commit()

    return {"message": "تمت الاستعادة بنجاح. يُنصح بإعادة تشغيل الخادم."}
