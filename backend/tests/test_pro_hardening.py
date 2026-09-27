# tests/test_pro_hardening.py
"""إحكام الاحترافية: أرقام فريدة تحت الضغط، منع السحب فوق الرصيد،
تجميع المانحين، ترقيم الصفحات، /v1، وترويسة معرّف الطلب."""
from tests.conftest import api_login


def _h(token):
    return {"Authorization": f"Bearer {token}"}


def _token(client, admin_user):
    return api_login(client, "admin_test", "TestPass123")["access_token"]


def _seed(client, token):
    assert client.post("/accounts/seed-defaults", json={}, headers=_h(token)).status_code in (200, 201)
    rows = client.get("/accounts", headers=_h(token)).json()
    cash = next(a for a in rows if a["type"] == "asset" and a["is_cash"])
    income = next(a for a in rows if a["type"] == "income")
    return cash, income


def _receipt(client, token, cash, income, amount, donor_id=None):
    return client.post("/vouchers", json={
        "kind": "قبض", "amount": amount, "voucher_date": "2026-09-01",
        "method": "نقداً", "description": "تحصيل", "party_name": "جهة",
        "treasury_account_id": cash["id"], "counter_account_id": income["id"],
    } | ({"donor_id": donor_id} if donor_id else {}), headers=_h(token))


def test_numbers_stay_unique_under_rapid_creation(client, admin_user):
    """25 سنداً متتاليا: كل رقم سند وكل رقم قيد فريد (العداد الذرّي)."""
    token = _token(client, admin_user)
    cash, income = _seed(client, token)
    nos = set()
    for i in range(25):
        r = _receipt(client, token, cash, income, 100 + i)
        assert r.status_code == 201, r.text
        nos.add(r.json()["voucher_no"])
    assert len(nos) == 25
    entries = client.get("/journal?entry_type=voucher_receipt", headers=_h(token)).json()
    enos = [e["entry_no"] for e in entries]
    assert len(set(enos)) == len(enos) == 25


def test_payment_voucher_cannot_overdraw(client, admin_user):
    token = _token(client, admin_user)
    cash, income = _seed(client, token)
    assert _receipt(client, token, cash, income, 500).status_code == 201
    pay = client.post("/vouchers", json={
        "kind": "صرف", "amount": 400, "voucher_date": "2026-09-02", "method": "نقداً",
        "description": "مصروف", "party_name": "جهة",
        "treasury_account_id": cash["id"], "counter_account_id": income["id"],
    }, headers=_h(token))
    assert pay.status_code == 201, pay.text  # المتاح 500
    over = client.post("/vouchers", json={
        "kind": "صرف", "amount": 200, "voucher_date": "2026-09-03", "method": "نقداً",
        "description": "مصروف زائد", "party_name": "جهة",
        "treasury_account_id": cash["id"], "counter_account_id": income["id"],
    }, headers=_h(token))
    assert over.status_code == 400  # المتاح 100 فقط
    assert "غير كافٍ" in over.json()["detail"]


def test_donors_totals_from_single_aggregate(client, admin_user):
    token = _token(client, admin_user)
    cash, income = _seed(client, token)
    d1 = client.post("/donors", json={"name": "مانح واحد"}, headers=_h(token)).json()
    d2 = client.post("/donors", json={"name": "مانح اثنان"}, headers=_h(token)).json()
    assert _receipt(client, token, cash, income, 700, donor_id=d1["id"]).status_code == 201
    assert _receipt(client, token, cash, income, 300, donor_id=d2["id"]).status_code == 201
    rows = {r["name"]: r["total_donated"] for r in client.get("/donors", headers=_h(token)).json()}
    assert rows["مانح واحد"] == 700 and rows["مانح اثنان"] == 300


def test_pagination_headers_and_request_id(client, admin_user):
    token = _token(client, admin_user)
    cash, income = _seed(client, token)
    for i in range(3):
        assert _receipt(client, token, cash, income, 100 + i).status_code == 201
    r = client.get("/vouchers?limit=1&offset=0", headers=_h(token))
    assert r.status_code == 200
    assert len(r.json()) == 1
    assert r.headers.get("x-total-count") == "3"
    assert r.headers.get("x-request-id")


def test_v1_surface_live(client):
    r = client.get("/v1/journal/entry-types")
    assert r.status_code == 200
    assert isinstance(r.json(), list) and len(r.json()) > 0
