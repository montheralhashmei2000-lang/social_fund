# app/main.py
"""
نقطة دخول الخادم - نسخة نظام أونلاين بالكامل.

أهم تغيير عن النسخة السابقة: أُزيلت طبقة المزامنة (/sync/pull و /sync/push)
نهائياً لأن التطبيق الجديد (Flutter) يعمل على الإنترنت فقط. إزالة المسار
تلغي جذر الثغرة الحرجة رقم 1 في تقرير الفحص (تجاوز RBAC عبر المزامنة)
وكذلك الملاحظات 2 و5 و6 و7 و29 المرتبطة بها.

كما يُرفض الإقلاع في الإنتاج إذا كانت الإعدادات غير آمنة (الملاحظتان 10 و11)
ويُضبط CORS بصرامة (الملاحظة 16) وتُضاف ترويسات أمان أساسية.
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import os

from app.core.config import settings, validate_production_settings
from app.core.database import Base, engine, SessionLocal
from app.routers import (
    auth, members, aids, subscriptions, treasury, vouchers,
    messages, events, fund_settings, reports, backup, audit, users, push, admin,
    accounts, journal, donors, campaigns, beneficiaries, inkind, budgets, reports_financial,
    card_verify,
)

# يفشل فوراً عند الإقلاع إذا كانت مفاتيح الإنتاج غير مضبوطة.
validate_production_settings(settings.ENV, settings.SECRET_KEY, settings.FIELD_ENCRYPTION_KEY, settings.CORS_ORIGINS)

# ===== المراقبة (اختيارية): فعّلها بضبط SENTRY_DSN + pip install sentry-sdk[fastapi] =====
if os.environ.get("SENTRY_DSN"):
    try:
        import sentry_sdk
        sentry_sdk.init(dsn=os.environ["SENTRY_DSN"], traces_sample_rate=0.1)
    except ImportError:
        import logging as _l
        _l.getLogger("uvicorn.error").warning("SENTRY_DSN مضبوط لكن sentry-sdk غير مثبت - تجاهل")

app = FastAPI(
    title=settings.APP_NAME,
    description="واجهة برمجية لإدارة الصندوق الاجتماعي التنموي - مصادقة، صلاحيات، تقارير، نسخ احتياطي. نظام أونلاين فقط.",
    version="2.0.0",
)

_origins = settings.cors_origins_list
app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    # لا يجوز الجمع بين "*" وallow_credentials - يُعطَّل تلقائياً معWildcard.
    allow_credentials="*" not in _origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def security_headers(request: Request, call_next):
    """ترويسات أمان + معرّف طلب فريد (X-Request-ID) + سجل JSON منظم لكل طلب."""
    import json as _json
    import logging as _logging
    import time as _time
    import uuid as _uuid

    started = _time.time()
    response = await call_next(request)
    rid = _uuid.uuid4().hex[:12]
    response.headers.setdefault("X-Request-ID", rid)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    try:
        _logging.getLogger("app.access").info(_json.dumps({
            "request_id": rid, "method": request.method, "path": request.url.path,
            "status": response.status_code, "ms": round((_time.time() - started) * 1000, 1),
        }, ensure_ascii=False))
    except Exception:
        pass
    return response


# إنشاء الجداول يبقى مقتصراً على بيئة التطوير فقط؛ الإنتاج يعتمد على Alembic حصراً
# (`alembic upgrade head`) - الملاحظة 24.
if settings.ENV == "development":
    Base.metadata.create_all(bind=engine)
    from app.services.accounting_seed import ensure_default_accounts
    _seed_db = SessionLocal()
    try:
        ensure_default_accounts(_seed_db)
    finally:
        _seed_db.close()

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(members.router)
app.include_router(aids.router)
app.include_router(subscriptions.router)
app.include_router(treasury.router)
app.include_router(vouchers.router)
app.include_router(messages.router)
app.include_router(events.router)
app.include_router(fund_settings.router)
app.include_router(reports.router)
app.include_router(backup.router)
app.include_router(audit.router)
app.include_router(push.router)
app.include_router(admin.router)
app.include_router(accounts.router)
app.include_router(journal.router)
app.include_router(donors.router)
app.include_router(campaigns.router)
app.include_router(beneficiaries.router)
app.include_router(inkind.router)
app.include_router(budgets.router)
app.include_router(reports_financial.router)
app.include_router(card_verify.router)


# ===== واجهة مُصدرة بإصدار: نفس الراوترات تحت /v1 (القديم يعمل للتوافق) =====
import importlib as _importlib

for _name in ("auth", "users", "members", "aids", "subscriptions", "treasury", "vouchers",
              "messages", "events", "fund_settings", "reports", "backup", "audit", "push",
              "admin", "accounts", "journal", "donors", "campaigns", "beneficiaries",
              "inkind", "budgets", "reports_financial", "card_verify"):
    try:
        app.include_router(_importlib.import_module(f"app.routers.{_name}").router, prefix="/v1")
    except ModuleNotFoundError:
        pass  # راوتر غير موجود في هذا التخطيط - تجاهل


@app.get("/")
def root():
    return {"status": "ok", "service": settings.APP_NAME}


@app.get("/health")
def health_check():
    return {"status": "healthy"}

# ===== وسائط الملفات (الشعار) — تخزين ملف بدل قاعدة البيانات =====
from fastapi.staticfiles import StaticFiles  # noqa: E402

MEDIA_DIR = Path(os.environ.get("MEDIA_DIR", "./media"))
MEDIA_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=str(MEDIA_DIR)), name="media")
