# tests/test_auth.py
"""تدفق الدخول الكامل، رفض البيانات الخاطئة، حظر المحاولات المتكررة، وعدم إعادة استخدام OTP."""
from tests.conftest import OTP_STORE, api_login


def test_full_login_flow_succeeds(client, admin_user):
    step1 = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    assert step1.status_code == 200
    otp_token = step1.json()["otp_token"]
    code = OTP_STORE["last"]

    step2 = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": code})
    assert step2.status_code == 200
    body = step2.json()
    assert "access_token" in body
    assert "refresh_token" in body


def test_wrong_password_rejected(client, admin_user):
    resp = client.post("/auth/login", json={"username": "admin_test", "password": "WrongPassword"})
    assert resp.status_code == 401


def test_otp_cannot_be_reused(client, admin_user):
    step1 = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    otp_token = step1.json()["otp_token"]
    code = OTP_STORE["last"]

    first_try = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": code})
    assert first_try.status_code == 200

    second_try = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": code})
    assert second_try.status_code == 401


def test_wrong_otp_code_rejected(client, admin_user):
    step1 = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    otp_token = step1.json()["otp_token"]

    resp = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": "000000"})
    assert resp.status_code == 401


def test_rate_limit_blocks_after_repeated_failures(client, admin_user):
    for _ in range(5):
        client.post("/auth/login", json={"username": "admin_test", "password": "WrongPassword"})

    resp = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    assert resp.status_code == 429


def test_inactive_account_rejected(client, db_session, admin_user):
    admin_user.is_active = False
    db_session.commit()

    resp = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    assert resp.status_code == 403


def test_me_endpoint(client, admin_user):
    tokens = api_login(client, "admin_test", "TestPass123")
    resp = client.get("/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"})
    assert resp.status_code == 200
    assert resp.json()["username"] == "admin_test"
