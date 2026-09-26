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

from app.core.config import settings, validate_production_settings
from app.core.database import Base, engine, SessionLocal
from app.routers import (
    auth, members, aids, subscriptions, treasury, vouchers,
    messages, events, fund_settings, reports, backup, audit, users, push, admin,
    accounts, journal, donors, campaigns, beneficiaries, inkind, budgets, reports_financial,
)

# يفشل فوراً عند الإقلاع إذا كانت مفاتيح الإنتاج غير مضبوطة.
validate_production_settings(settings.ENV, settings.SECRET_KEY, settings.FIELD_ENCRYPTION_KEY, settings.CORS_ORIGINS)

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
    response = await call_next(request)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
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


@app.get("/")
def root():
    return {"status": "ok", "service": settings.APP_NAME}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
