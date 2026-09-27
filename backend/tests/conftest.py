# tests/conftest.py
"""
الاختبارات تُشغَّل ضد SQLite في الذاكرة (`pytest` فقط دون خادم قاعدة بيانات).

OTP: بما أن الرموز تُخزَّن مجزّأة (SHA-256) لا يمكن قراءتها من قاعدة البيانات،
فإن fixture التُقاطع يستبدل دالة الإرسال في راوتر المصادقة ويلتقط الرمز
الصريح في OTP_STORE لاستخدامه في الاختبارات.
"""
import os

os.environ.setdefault("DATABASE_URL", "sqlite:///:memory:")
os.environ.setdefault("SECRET_KEY", "test-secret-key-not-for-production")
os.environ.setdefault("FIELD_ENCRYPTION_KEY", "zH5aGqYw6xVj8mQwB3nR2pL9sK4tN7cF1dE0uI6oA8s=")
os.environ.setdefault("ENV", "test")

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.core.security import hash_password
from app.models.user import User, RoleEnum
from app.models.fund_settings import FundSettings
from app.main import app

engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# آخر رمز OTP مُولَّد أثناء الاختبار (يلتقطه fixture _capture_otp)
OTP_STORE = {}


@pytest.fixture(scope="function")
def db_session():
    """جلسة قاعدة بيانات نظيفة لكل اختبار على حدة."""
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """عميل FastAPI تجريبي يستخدم نفس جلسة db_session."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def _capture_otp(monkeypatch):
    """يلتقط رمز OTP الصريح قبل تشفيره - التخزين في قاعدة البيانات مجزّأ."""
    OTP_STORE.clear()
    from app.routers import auth as auth_router

    def _fake_send(phone, code):
        OTP_STORE["last"] = code
        return "printed"

    monkeypatch.setattr(auth_router, "send_otp_sms", _fake_send)
    yield


@pytest.fixture(autouse=True)
def _reset_rate_limit_state():
    """تنظيف حالة rate limiter بين الاختبارات (متغيرات وحدة عامة)."""
    from app.services import rate_limit_service
    yield
    rate_limit_service.reset_all()
    rate_limit_service.reset_all()


def api_login(client, username, password):
    """تسجيل دخول كامل عبر API (كلمة مرور ← OTP ← رموز). يعيد TokenResponse كاملاً."""
    step1 = client.post("/auth/login", json={"username": username, "password": password})
    assert step1.status_code == 200, step1.text
    otp_token = step1.json()["otp_token"]
    code = OTP_STORE.get("last")
    assert code, "لم يُلتقط رمز OTP"
    step2 = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": code})
    assert step2.status_code == 200, step2.text
    return step2.json()


@pytest.fixture
def admin_user(db_session):
    user = User(
        username="admin_test",
        password_hash=hash_password("TestPass123"),
        full_name="مدير الاختبار",
        role=RoleEnum.admin,
        avatar_initial="م",
        is_active=True,
        phone="777000000",
    )
    db_session.add(user)
    db_session.add(FundSettings(name="صندوق الاختبار"))
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def viewer_user(db_session):
    user = User(
        username="viewer_test",
        password_hash=hash_password("TestPass123"),
        full_name="مراقب الاختبار",
        role=RoleEnum.viewer,
        avatar_initial="ر",
        is_active=True,
        phone="777000001",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user
