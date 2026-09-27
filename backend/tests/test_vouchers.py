# tests/test_vouchers.py
"""السندات مربوطة بالبنية المعمارية: كل سند قبض/صرف يولّد قيد يومية متوازن
ومرآة خزينة، والحسابات تتحرك، والإلغاء بقيد عكسي، والصلاحيات مطبقة."""
from tests.conftest import api_login


def _token(client, admin_user):
    return api_login(client, "admin_test", "TestPass123")["access_token"]


def _h(token):
    return {"Authorization": f"Bearer {token}"}


def _seed_accounts(client, token):
    assert client.post("/accounts/seed-defaults", json={}, headers=_h(token)).status_code in (200, 201)
    rows = client.get("/accounts", headers=_h(token)).json()
    cash = next(a for a in rows if a["type"] == "asset" and a["is_cash"])
    income = next(a for a in rows if a["type"] == "income")
    expense = next(a for a in rows if a["type"] == "expense")
    return cash, income, expense


def _member(client, token):
    resp = client.post("/members", json={
        "name": "عضو السندات", "national_id": "4455667788",
        "phone": "775555555", "monthly_subscription": 300,
    }, headers=_h(token))
    assert resp.status_code == 201
    return resp.json()


def _account(client, token, account_id):
    rows = client.get("/accounts", headers=_h(token)).json()
    return next(a for a in rows if a["id"] == account_id)


def _receipt(client, token, member, cash, income, amount=1000):
    return client.post("/vouchers", json={
        "kind": "قبض", "amount": amount, "voucher_date": "2026-09-01",
        "method": "نقداً", "description": "تحصيل اشتراك", "member_id": member["id"],
        "treasury_account_id": cash["id"], "counter_account_id": income["id"],
    }, headers=_h(token))


def test_receipt_voucher_posts_balanced_entry_and_treasury_mirror(client, admin_user):
    token = _token(client, admin_user)
    cash, income, _ = _seed_accounts(client, token)
    member = _member(client, token)

    resp = _receipt(client, token, member, cash, income)
    assert resp.status_code == 201, resp.text
    v = resp.json()
    assert v["journal_entry_no"] and v["journal_entry_no"].startswith("JE-")
    assert v["party_name"] == member["name"]
    assert v["journal_entry_id"]

    # القيد متوازن ومربوط بالسند في دفتر القيود
    entries = client.get("/journal?entry_type=voucher_receipt", headers=_h(token)).json()
    entry = next(e for e in entries if e["entry_no"] == v["journal_entry_no"])
    assert sum(l["debit"] for l in entry["lines"]) == sum(l["credit"] for l in entry["lines"]) == 1000
    assert entry["reference"] == v["voucher_no"]
    assert entry["member_id"] == member["id"]

    # مرآة الخزينة ظهرت في شاشة الخزينة برقم السند
    treasury = client.get("/treasury", headers=_h(token)).json()
    assert any(t["reference_no"] == v["voucher_no"] and t["type"] == "إيراد" for t in treasury)


def test_voucher_moves_account_balances(client, admin_user):
    token = _token(client, admin_user)
    cash, income, expense = _seed_accounts(client, token)
    member = _member(client, token)

    assert _receipt(client, token, member, cash, income, amount=1000).status_code == 201
    assert _account(client, token, cash["id"])["balance"] == 1000

    pay = client.post("/vouchers", json={
        "kind": "صرف", "amount": 400, "voucher_date": "2026-09-02",
        "method": "نقداً", "description": "مساعدة عاجلة", "member_id": member["id"],
        "treasury_account_id": cash["id"], "counter_account_id": expense["id"],
    }, headers=_h(token))
    assert pay.status_code == 201, pay.text
    assert _account(client, token, cash["id"])["balance"] == 600

    treasury = client.get("/treasury", headers=_h(token)).json()
    assert any(t["reference_no"] == pay.json()["voucher_no"] and t["type"] == "مصروف" for t in treasury)


def test_void_voucher_creates_reversing_entry(client, admin_user):
    token = _token(client, admin_user)
    cash, income, _ = _seed_accounts(client, token)
    member = _member(client, token)
    v = _receipt(client, token, member, cash, income).json()

    void = client.post(f"/vouchers/{v['id']}/void", headers=_h(token))
    assert void.status_code == 200, void.text
    assert void.json()["status"] == "ملغي"

    # الأرصدة عادت للصفر بقيد عكسي (القيد الأصلي بقي موثقاً)
    assert _account(client, token, cash["id"])["balance"] == 0
    # مرآة الخزينة عُطّلت
    treasury = client.get("/treasury", headers=_h(token)).json()
    assert not any(t["reference_no"] == v["voucher_no"] for t in treasury)
    # إلغاء مرة ثانية مرفوض
    assert client.post(f"/vouchers/{v['id']}/void", headers=_h(token)).status_code == 400


def test_voucher_validation_and_permissions(client, admin_user, viewer_user):
    token = _token(client, admin_user)
    cash, income, _ = _seed_accounts(client, token)
    member = _member(client, token)

    # بدون طرف
    no_party = client.post("/vouchers", json={
        "kind": "قبض", "amount": 100, "voucher_date": "2026-09-01", "method": "نقداً",
        "description": "x", "treasury_account_id": cash["id"], "counter_account_id": income["id"],
    }, headers=_h(token))
    assert no_party.status_code == 400

    # حسابان متطابقان
    same = client.post("/vouchers", json={
        "kind": "قبض", "amount": 100, "voucher_date": "2026-09-01", "method": "نقداً",
        "description": "x", "member_id": member["id"],
        "treasury_account_id": cash["id"], "counter_account_id": cash["id"],
    }, headers=_h(token))
    assert same.status_code == 400

    # قبض على حساب غير نقدي مرفوض
    bad_acc = client.post("/vouchers", json={
        "kind": "قبض", "amount": 100, "voucher_date": "2026-09-01", "method": "نقداً",
        "description": "x", "member_id": member["id"],
        "treasury_account_id": income["id"], "counter_account_id": cash["id"],
    }, headers=_h(token))
    assert bad_acc.status_code == 400

    # إيداع قبلي حتى يسمح سند الصرف (حماية السحب فوق الرصيد)
    _receipt(client, token, member, cash, income, amount=900)
    # سند جهة حرة (بدون سجل) يعمل
    free = client.post("/vouchers", json={
        "kind": "صرف", "amount": 250, "voucher_date": "2026-09-03", "method": "نقداً",
        "description": "مصروفات نثرية", "party_name": "عامل تنظيف",
        "treasury_account_id": cash["id"], "counter_account_id": expense_id(client, token),
    }, headers=_h(token))
    assert free.status_code == 201, free.text
    assert free.json()["party_name"] == "عامل تنظيف"

    # viewer ممنوع من السندات
    vtoken = api_login(client, "viewer_test", "TestPass123")["access_token"]
    assert client.get("/vouchers", headers=_h(vtoken)).status_code == 403


def expense_id(client, token):
    rows = client.get("/accounts", headers=_h(token)).json()
    return next(a["id"] for a in rows if a["type"] == "expense")
