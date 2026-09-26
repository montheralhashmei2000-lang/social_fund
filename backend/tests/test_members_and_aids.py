# tests/test_members_and_aids.py
"""إنشاء/تعديل/حذف الأعضاء، دورة حياة طلب المساعدة، ومنع الانتقالات غير المنطقية."""
from tests.conftest import api_login


def _admin_token(client, admin_user):
    return api_login(client, "admin_test", "TestPass123")["access_token"]


def _create_member(client, token, national_id="3333333333"):
    resp = client.post(
        "/members",
        json={"name": "عضو الاختبار", "national_id": national_id, "phone": "777333333", "monthly_subscription": 500},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    return resp.json()


def test_national_id_encrypted_at_rest(client, db_session, admin_user):
    from app.models.member import Member
    from sqlalchemy import text

    token = _admin_token(client, admin_user)
    created = _create_member(client, token, national_id="9999999999")

    raw_value = db_session.execute(
        text("SELECT national_id FROM members WHERE id = :id"), {"id": str(created["id"])}
    ).scalar()
    assert raw_value != "9999999999"

    get_resp = client.get(f"/members/{created['id']}", headers={"Authorization": f"Bearer {token}"})
    assert get_resp.json()["national_id"] == "9999999999"


def test_duplicate_national_id_rejected(client, admin_user):
    token = _admin_token(client, admin_user)
    _create_member(client, token, national_id="4444444444")

    resp = client.post(
        "/members",
        json={"name": "عضو آخر", "national_id": "4444444444", "phone": "777444444", "monthly_subscription": 500},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 400


def test_member_soft_delete(client, admin_user):
    token = _admin_token(client, admin_user)
    member = _create_member(client, token, national_id="5555555555")

    del_resp = client.delete(f"/members/{member['id']}", headers={"Authorization": f"Bearer {token}"})
    assert del_resp.status_code == 200

    list_resp = client.get("/members", headers={"Authorization": f"Bearer {token}"})
    ids = [m["id"] for m in list_resp.json()]
    assert member["id"] not in ids


def test_aid_request_full_lifecycle(client, admin_user):
    token = _admin_token(client, admin_user)
    member = _create_member(client, token, national_id="6666666666")
    headers = {"Authorization": f"Bearer {token}"}

    create_resp = client.post(
        "/aids",
        json={"member_id": member["id"], "aid_type": "مساعدة زواج", "amount": 5000, "request_date": "2025-01-01"},
        headers=headers,
    )
    assert create_resp.status_code == 201
    aid = create_resp.json()
    assert aid["status"] == "قيد المراجعة"

    # فصل المهام (maker-checker): صانع الطلب لا يعتمده بنفسه
    self_approve = client.patch(f"/aids/{aid['id']}/status", json={"status": "معتمدة"}, headers=headers)
    assert self_approve.status_code == 403

    # مستخدم معتمد ثانٍ يراجع الطلب ويعتمده
    create_user = client.post(
        "/users",
        json={"username": "approver_test", "password": "TestPass123", "full_name": "معتمد ثانٍ", "role": "admin"},
        headers=headers,
    )
    assert create_user.status_code == 201, create_user.text
    approver_token = api_login(client, "approver_test", "TestPass123")["access_token"]

    approve_resp = client.patch(
        f"/aids/{aid['id']}/status", json={"status": "معتمدة"},
        headers={"Authorization": f"Bearer {approver_token}"},
    )
    assert approve_resp.status_code == 200
    assert approve_resp.json()["status"] == "معتمدة"

    # الصرف متاح لصانع الطلب بعد اعتماده من جهة مستقلة
    disburse_resp = client.patch(f"/aids/{aid['id']}/status", json={"status": "مصروفة"}, headers=headers)
    assert disburse_resp.status_code == 200
    assert disburse_resp.json()["status"] == "مصروفة"


def test_aid_request_invalid_transition_rejected(client, admin_user):
    token = _admin_token(client, admin_user)
    member = _create_member(client, token, national_id="7777777777")
    headers = {"Authorization": f"Bearer {token}"}

    create_resp = client.post(
        "/aids",
        json={"member_id": member["id"], "aid_type": "مساعدة مرضية", "amount": 1000, "request_date": "2025-01-01"},
        headers=headers,
    )
    aid = create_resp.json()

    client.patch(f"/aids/{aid['id']}/status", json={"status": "مرفوضة"}, headers=headers)

    invalid_resp = client.patch(f"/aids/{aid['id']}/status", json={"status": "معتمدة"}, headers=headers)
    assert invalid_resp.status_code == 400


def test_subscription_updates_member_totals(client, admin_user):
    token = _admin_token(client, admin_user)
    member = _create_member(client, token, national_id="8888888888")
    headers = {"Authorization": f"Bearer {token}"}

    sub_resp = client.post(
        "/subscriptions",
        json={"member_id": member["id"], "amount": 500, "payment_date": "2025-01-01", "method": "نقداً"},
        headers=headers,
    )
    assert sub_resp.status_code == 201

    updated_member = client.get(f"/members/{member['id']}", headers=headers).json()
    assert updated_member["total_paid"] == 500
