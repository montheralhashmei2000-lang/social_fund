# tests/test_security_fixes.py
"""
اختبارات أمنية لإصلاحات تقرير الفحص:
  - إزالة طبقة المزامنة (الثغرة الحرجة 1)
  - ملكية push token (الملاحظة 3)
  - تدوير refresh tokens وإلغاؤها (الملاحظة 21)
  - سياسة كلمة المرور (الملاحظة 26)
  - عدم كشف الهواتف في قائمة الزملاء (الملاحظة 4)
  - تخزين OTP مجزّأ (الملاحظة 18)
  - فحوصات إعدادات الإنتاج (الملاحظتان 10 و11)
  - فشل SMS في الإنتاج يعيد 503 دون طباعة الرمز (الملاحظة 17)
"""
import pytest

from app.models.device_token import DeviceToken
from app.models.otp_code import OtpCode
from tests.conftest import api_login, OTP_STORE


def _auth(token):
    return {"Authorization": f"Bearer {token}"}


def test_sync_endpoints_removed(client, admin_user):
    """المزامنة أُزيلت نهائياً (نظام أونلاين فقط) - لا مسار يتيح تجاوز RBAC."""
    tokens = api_login(client, "admin_test", "TestPass123")
    headers = _auth(tokens["access_token"])
    assert client.post("/sync/push", json={"device_id": "d", "items": []}, headers=headers).status_code == 404
    assert client.post("/sync/pull", json={}, headers=headers).status_code == 404


def test_unregister_token_requires_ownership(client, db_session, admin_user, viewer_user):
    """مستخدم آخر لا يستطيع إلغاء تسجيل token لا يملكه (الملاحظة 3)."""
    admin_tokens = api_login(client, "admin_test", "TestPass123")
    reg = client.post("/push/register-token", json={"token": "TOK-ADMIN-1", "platform": "android"},
                      headers=_auth(admin_tokens["access_token"]))
    assert reg.status_code == 200

    viewer_tokens = api_login(client, "viewer_test", "TestPass123")
    resp = client.post("/push/unregister-token", json={"token": "TOK-ADMIN-1"},
                       headers=_auth(viewer_tokens["access_token"]))
    assert resp.status_code == 404
    assert db_session.query(DeviceToken).filter(DeviceToken.token == "TOK-ADMIN-1").count() == 1

    ok = client.post("/push/unregister-token", json={"token": "TOK-ADMIN-1"},
                     headers=_auth(admin_tokens["access_token"]))
    assert ok.status_code == 200
    assert db_session.query(DeviceToken).filter(DeviceToken.token == "TOK-ADMIN-1").count() == 0


def test_refresh_rotates_and_old_token_dies(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    r1 = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r1.status_code == 200
    new_tokens = r1.json()
    assert new_tokens["refresh_token"] != tokens["refresh_token"]

    r2 = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r2.status_code == 401

    r3 = client.post("/auth/refresh", json={"refresh_token": new_tokens["refresh_token"]})
    assert r3.status_code == 200


def test_logout_revokes_refresh_token(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    resp = client.post("/auth/logout", json={"refresh_token": tokens["refresh_token"]},
                       headers=_auth(tokens["access_token"]))
    assert resp.status_code == 200
    assert resp.json()["session_revoked"] is True

    r = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 401


def test_logout_all_revokes_every_session(client, admin_user):
    t1 = api_login(client, "admin_test", "TestPass123")
    t2 = api_login(client, "admin_test", "TestPass123")
    resp = client.post("/auth/logout-all", json={}, headers=_auth(t1["access_token"]))
    assert resp.status_code == 200
    for t in (t1, t2):
        r = client.post("/auth/refresh", json={"refresh_token": t["refresh_token"]})
        assert r.status_code == 401


def test_change_password_min_length_rejected(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    resp = client.post("/auth/change-password",
                       json={"old_password": "TestPass123", "new_password": "short1"},
                       headers=_auth(tokens["access_token"]))
    assert resp.status_code == 400


def test_change_password_revokes_all_sessions(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    resp = client.post("/auth/change-password",
                       json={"old_password": "TestPass123", "new_password": "NewStrongPass1"},
                       headers=_auth(tokens["access_token"]))
    assert resp.status_code == 200
    r = client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 401


def test_colleagues_do_not_leak_phone(client, admin_user, viewer_user):
    """قائمة الزملاء بلا أرقام هواتف (الملاحظة 4)."""
    tokens = api_login(client, "viewer_test", "TestPass123")
    resp = client.get("/users/colleagues", headers=_auth(tokens["access_token"]))
    assert resp.status_code == 200
    for row in resp.json():
        assert "phone" not in row


def test_create_user_short_password_rejected(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    resp = client.post("/users",
                       json={"username": "newbie", "password": "123", "full_name": "مستخدم جديد", "role": "viewer"},
                       headers=_auth(tokens["access_token"]))
    assert resp.status_code == 400


def test_otp_stored_hashed(client, db_session, admin_user):
    """الرمز في قاعدة البيانات مجزّأ وليس نصاً صريحاً (الملاحظة 18)."""
    client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    code = OTP_STORE["last"]

    entry = db_session.query(OtpCode).first()
    assert entry is not None
    assert entry.code != code
    assert len(entry.code) == 64  # sha256 hex digest


def test_production_settings_validation():
    """الإقلاع في الإنتاج يُرفض مع المفاتيح الافتراضية أو CORS مفتوح (10، 11، 16)."""
    from app.core.config import validate_production_settings

    valid_key = "zH5aGqYw6xVj8mQwB3nR2pL9sK4tN7cF1dE0uI6oA8s="

    with pytest.raises(RuntimeError):
        validate_production_settings("production",
                                     "CHANGE_ME_TO_A_LONG_RANDOM_SECRET_IN_PRODUCTION", valid_key,
                                     "https://app.example.com")
    with pytest.raises(RuntimeError):
        validate_production_settings("production", "a" * 40, "CHANGE_ME", "https://app.example.com")
    with pytest.raises(RuntimeError):
        validate_production_settings("production", "a" * 40, valid_key, "*")
    with pytest.raises(RuntimeError):
        validate_production_settings("production", "a" * 40, valid_key, "")

    # إعدادات سليمة لا ترمي
    validate_production_settings("production", "a" * 40, valid_key, "https://app.example.com")
    # غير الإنتاج لا يفحص
    validate_production_settings("development", "CHANGE_ME", "CHANGE_ME", "*")


def test_sms_failure_in_production_returns_503_and_keeps_no_otp(client, db_session, admin_user, monkeypatch):
    """فشل إرسال SMS في الإنتاج يعيد 503 ولا يُبقي رمزاً ولا يطبعه (الملاحظة 17)."""
    from app.routers import auth as auth_router
    from app.core.config import settings

    monkeypatch.setattr(settings, "ENV", "production")
    monkeypatch.setattr(auth_router, "send_otp_sms", lambda phone, code: "failed")

    resp = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    assert resp.status_code == 503
    assert db_session.query(OtpCode).count() == 0
