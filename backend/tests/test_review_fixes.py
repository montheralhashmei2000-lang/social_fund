# tests/test_review_fixes.py
"""اختبارات انحدار لإصلاحات المراجعة: ترقيم القيود، المبالغ السالبة، حد OTP لكل رمز،
حماية المدير من قفل نفسه، ورفض شعار SVG."""
from tests.conftest import api_login, OTP_STORE
from tests.test_vouchers import _token, _h, _seed_accounts, _member, _receipt


def test_entry_numbers_never_collide_across_creators(client, admin_user):
    """سند (كان يعدّ الصفوف) ثم قيد يدوي (كان يستخدم عدّاداً) ثم سند: أرقام فريدة دائماً."""
    token = _token(client, admin_user)
    cash, income, _ = _seed_accounts(client, token)
    member = _member(client, token)

    nos = []
    for _ in range(2):
        r = _receipt(client, token, member, cash, income, amount=100)
        assert r.status_code == 201, r.text
        nos.append(r.json()["journal_entry_no"])
    j = client.post("/journal", json={
        "entry_date": "2026-09-02", "description": "يدوي", "entry_type": "adjustment",
        "lines": [{"account_id": cash["id"], "debit": 50},
                  {"account_id": income["id"], "credit": 50}],
    }, headers=_h(token))
    assert j.status_code == 201, j.text
    nos.append(j.json()["entry_no"])
    r = _receipt(client, token, member, cash, income, amount=100)
    assert r.status_code == 201, r.text
    nos.append(r.json()["journal_entry_no"])

    assert len(set(nos)) == len(nos), nos


def test_journal_rejects_negative_lines(client, admin_user):
    token = _token(client, admin_user)
    cash, income, expense = _seed_accounts(client, token)
    # مدين 100 + مدين -50 مقابل دائن 50: متوازن ظاهرياً لكن فيه سطر سالب
    resp = client.post("/journal", json={
        "entry_date": "2026-09-02", "description": "سالب", "entry_type": "adjustment",
        "lines": [{"account_id": cash["id"], "debit": 100},
                  {"account_id": expense["id"], "debit": -50},
                  {"account_id": income["id"], "credit": 50}],
    }, headers=_h(token))
    assert resp.status_code == 400


def test_non_positive_amounts_rejected(client, admin_user):
    token = _token(client, admin_user)
    r = client.post("/treasury", json={
        "type": "إيراد", "category": "تبرع", "description": "x", "amount": -5,
        "entry_date": "2026-09-01"}, headers=_h(token))
    assert r.status_code == 422
    r = client.post("/aids", json={
        "member_id": "x", "aid_type": "طارئة", "amount": 0,
        "request_date": "2026-09-01"}, headers=_h(token))
    assert r.status_code == 422


def test_otp_limit_is_per_token_even_if_client_ip_rotates(client, admin_user):
    """تزوير X-Forwarded-For لا يمنح محاولات إضافية على نفس رمز التحقق."""
    step1 = client.post("/auth/login", json={"username": "admin_test", "password": "TestPass123"})
    otp_token = step1.json()["otp_token"]
    real = OTP_STORE["last"]
    wrong = "000000" if real != "000000" else "111111"
    for i in range(5):
        r = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": wrong},
                        headers={"X-Forwarded-For": f"10.0.0.{i + 1}"})
        assert r.status_code == 401
    # السادسة بـ IP جديد، وحتى بالرمز الصحيح: محظورة
    r = client.post("/auth/verify-otp", json={"otp_token": otp_token, "code": real},
                    headers={"X-Forwarded-For": "10.9.9.9"})
    assert r.status_code == 429


def test_admin_cannot_lock_themselves_out(client, admin_user):
    token = _token(client, admin_user)
    me = client.get("/auth/me", headers=_h(token)).json()
    assert client.put(f"/users/{me['id']}", json={"is_active": False}, headers=_h(token)).status_code == 400
    assert client.put(f"/users/{me['id']}", json={"role": "viewer"}, headers=_h(token)).status_code == 400
    assert client.put(f"/users/{me['id']}", json={"full_name": "اسم جديد"}, headers=_h(token)).status_code == 200


def test_svg_logo_rejected(client, admin_user):
    token = _token(client, admin_user)
    svg = b"<svg xmlns='http://www.w3.org/2000/svg'><script>alert(1)</script></svg>"
    r = client.put("/fund-settings/logo-file", files={"file": ("logo.svg", svg, "image/svg+xml")},
                   headers=_h(token))
    assert r.status_code == 400
