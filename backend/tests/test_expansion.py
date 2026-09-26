# tests/test_expansion.py
"""اختبارات التوسعة: قيد مزدوج، تحويلات، ميزان مراجعة، حملات، مانحون ووعود،
مستفيدون، مساعدات دورية، عينية، موازنات، وفصل المهام (maker-checker)."""
import pytest

from app.models.accounting import Account
from tests.conftest import api_login

TODAY = "2026-09-01"


def _token(client, admin_user):
    return api_login(client, "admin_test", "TestPass123")["access_token"]


def _h(token):
    return {"Authorization": f"Bearer {token}"}


def _seed_accounts(client, token):
    client.post("/accounts/seed-defaults", headers=_h(token))
    accounts = client.get("/accounts", headers=_h(token)).json()
    return {a["code"]: a for a in accounts}


def test_unbalanced_entry_rejected(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    resp = client.post("/journal", json={
        "entry_date": TODAY, "description": "قيد غير متوازن", "entry_type": "subscription",
        "lines": [
            {"account_id": accs["1010"]["id"], "debit": 500, "credit": 0},
            {"account_id": accs["4010"]["id"], "debit": 0, "credit": 400},
        ],
    }, headers=_h(token))
    assert resp.status_code == 400
    assert "غير متوازن" in resp.json()["detail"]


def test_balanced_entry_updates_balances(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    resp = client.post("/journal", json={
        "entry_date": TODAY, "description": "اشتراك عضو", "entry_type": "subscription",
        "lines": [
            {"account_id": accs["1010"]["id"], "debit": 500, "credit": 0},
            {"account_id": accs["4010"]["id"], "debit": 0, "credit": 500},
        ],
    }, headers=_h(token))
    assert resp.status_code == 201, resp.text
    assert resp.json()["entry_no"].startswith("JE-")

    balances = {a["code"]: a["balance"] for a in client.get("/accounts", headers=_h(token)).json()}
    assert balances["1010"] == 500.0
    assert balances["4010"] == 500.0


def test_internal_transfer_is_not_income(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    resp = client.post("/accounts/transfer", json={
        "from_account_id": accs["1020"]["id"], "to_account_id": accs["1010"]["id"],
        "amount": 1000, "description": "إيداع نقدي", "entry_date": TODAY,
    }, headers=_h(token))
    assert resp.status_code == 200

    balances = {a["code"]: a["balance"] for a in client.get("/accounts", headers=_h(token)).json()}
    assert balances["1020"] == -1000.0
    assert balances["1010"] == 1000.0
    assert balances["4010"] == 0.0


def test_trial_balance_is_balanced(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    client.post("/journal", json={
        "entry_date": TODAY, "description": "تبرع", "entry_type": "donation",
        "lines": [
            {"account_id": accs["1020"]["id"], "debit": 2500.50, "credit": 0},
            {"account_id": accs["4020"]["id"], "debit": 0, "credit": 2500.50},
        ],
    }, headers=_h(token))
    body = client.get(
        "/financial-reports/trial-balance?date_from=2026-09-01&date_to=2026-09-30",
        headers=_h(token)).json()
    assert body["balanced"] is True
    assert body["total_debit"] == pytest.approx(body["total_credit"])


def test_campaign_progress(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    camp = client.post("/campaigns", json={
        "name": "حملة رمضان", "goal_amount": 10000, "start_date": TODAY,
    }, headers=_h(token)).json()
    client.post("/journal", json={
        "entry_date": TODAY, "description": "تبرع للحملة", "entry_type": "campaign_donation",
        "campaign_id": camp["id"],
        "lines": [
            {"account_id": accs["1020"]["id"], "debit": 4000, "credit": 0},
            {"account_id": accs["4030"]["id"], "debit": 0, "credit": 4000},
        ],
    }, headers=_h(token))
    detail = client.get(f"/campaigns/{camp['id']}", headers=_h(token)).json()
    assert detail["raised"] == 4000.0
    assert detail["percent"] == 40.0


def test_donor_pledge_due_and_certificate(client, admin_user):
    token = _token(client, admin_user)
    donor = client.post("/donors", json={"name": "متجر الأمل", "donor_type": "merchant", "tier": "gold"},
                        headers=_h(token)).json()
    assert donor["tier_label"] == "ذهبي"

    pledge = client.post("/pledges", json={
        "donor_id": donor["id"], "amount": 1000, "frequency": "monthly", "start_date": "2026-08-01",
    }, headers=_h(token)).json()

    due = client.get("/pledges/due", headers=_h(token)).json()
    assert any(p["id"] == pledge["id"] for p in due)

    cert = client.get(f"/donors/{donor['id']}/certificate", headers=_h(token))
    assert cert.status_code == 200
    assert cert.content[:4] == b"%PDF"


def test_beneficiary_duplicate_nid_rejected(client, admin_user):
    token = _token(client, admin_user)
    assert client.post("/beneficiaries", json={"full_name": "مستفيد أول", "national_id": "1111111111"},
                       headers=_h(token)).status_code == 201
    assert client.post("/beneficiaries", json={"full_name": "مستفيد ثانٍ", "national_id": "1111111111"},
                       headers=_h(token)).status_code == 400


def test_periodic_aid_pay_once_per_period(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    ben = client.post("/beneficiaries", json={"full_name": "أرملة محمد"}, headers=_h(token)).json()
    pa = client.post("/periodic-aids", json={
        "beneficiary_id": ben["id"], "monthly_amount": 300, "started_on": TODAY,
    }, headers=_h(token)).json()

    pay = client.post(f"/periodic-aids/{pa['id']}/pay", json={
        "period": "2026-09", "from_account_id": accs["1010"]["id"],
        "expense_account_id": accs["5010"]["id"],
    }, headers=_h(token))
    assert pay.status_code == 200

    again = client.post(f"/periodic-aids/{pa['id']}/pay", json={
        "period": "2026-09", "from_account_id": accs["1010"]["id"],
        "expense_account_id": accs["5010"]["id"],
    }, headers=_h(token))
    assert again.status_code == 400


def test_inkind_stock_guards(client, admin_user):
    token = _token(client, admin_user)
    client.post("/inkind/items", json={"name": "سلة غذائية", "unit": "سلة"}, headers=_h(token))
    item_id = client.get("/inkind/items", headers=_h(token)).json()[0]["id"]

    assert client.post("/inkind/movements", json={
        "item_id": item_id, "direction": "in", "quantity": 50, "movement_date": TODAY,
    }, headers=_h(token)).status_code == 201

    assert client.post("/inkind/movements", json={
        "item_id": item_id, "direction": "out", "quantity": 100, "movement_date": TODAY,
    }, headers=_h(token)).status_code == 400

    out = client.post("/inkind/movements", json={
        "item_id": item_id, "direction": "out", "quantity": 20, "movement_date": TODAY,
    }, headers=_h(token))
    assert out.status_code == 201
    assert out.json()["new_quantity"] == 30.0


def test_budget_report(client, admin_user):
    token = _token(client, admin_user)
    accs = _seed_accounts(client, token)
    client.post("/budgets", json={
        "period": "2026-09", "account_id": accs["5030"]["id"], "planned_amount": 500,
    }, headers=_h(token))
    client.post("/journal", json={
        "entry_date": TODAY, "description": "قرطاسية", "entry_type": "expense",
        "lines": [
            {"account_id": accs["5030"]["id"], "debit": 300, "credit": 0},
            {"account_id": accs["1010"]["id"], "debit": 0, "credit": 300},
        ],
    }, headers=_h(token))

    rep = client.get("/budgets/2026-09/report", headers=_h(token)).json()
    assert rep["total_planned"] == 500.0
    assert rep["total_actual"] == 300.0
    assert rep["total_usage_pct"] == 60.0


def test_viewer_blocked_from_accounting(client, viewer_user):
    token = api_login(client, "viewer_test", "TestPass123")["access_token"]
    assert client.get("/accounts", headers=_h(token)).status_code == 403
    assert client.get("/journal", headers=_h(token)).status_code == 403
    assert client.get("/donors", headers=_h(token)).status_code == 403
    assert client.get("/beneficiaries", headers=_h(token)).status_code == 403


def test_maker_checker_self_approval_blocked(client, admin_user):
    """صانع الطلب لا يعتمده بنفسه (فصل المهام) - معالجة التوصية 3 من خارطة الطريق."""
    token = _token(client, admin_user)
    member = client.post("/members", json={
        "name": "عضو فصل المهام", "national_id": "1212121212", "phone": "777121212",
        "monthly_subscription": 500,
    }, headers=_h(token)).json()
    aid = client.post("/aids", json={
        "member_id": member["id"], "aid_type": "مساعدة مرضية", "amount": 1500,
        "request_date": TODAY,
    }, headers=_h(token)).json()

    resp = client.patch(f"/aids/{aid['id']}/status", json={"status": "معتمدة"}, headers=_h(token))
    assert resp.status_code == 403
    assert "فصل المهام" in resp.json()["detail"]
