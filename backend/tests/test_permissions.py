# tests/test_permissions.py
"""يتحقق أن RBAC يعمل: viewer يُمنع من الموارد غير المصرح بها والمسارات الإدارية."""
from tests.conftest import api_login


def test_viewer_cannot_create_member(client, viewer_user):
    token = api_login(client, "viewer_test", "TestPass123")["access_token"]
    resp = client.post(
        "/members",
        json={"name": "عضو تجريبي", "national_id": "1111111111", "phone": "777111111", "monthly_subscription": 500},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403


def test_viewer_cannot_access_user_management(client, viewer_user):
    token = api_login(client, "viewer_test", "TestPass123")["access_token"]
    resp = client.get("/users", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 403


def test_admin_can_create_member(client, admin_user):
    token = api_login(client, "admin_test", "TestPass123")["access_token"]
    resp = client.post(
        "/members",
        json={"name": "عضو تجريبي", "national_id": "2222222222", "phone": "777222222", "monthly_subscription": 500},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    assert resp.json()["name"] == "عضو تجريبي"


def test_no_token_rejected(client):
    resp = client.get("/members")
    assert resp.status_code == 401


def test_admin_only_reminder_endpoint_rejects_viewer(client, viewer_user):
    token = api_login(client, "viewer_test", "TestPass123")["access_token"]
    resp = client.post("/admin/run-reminders", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 403
