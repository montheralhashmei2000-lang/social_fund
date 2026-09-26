# app/core/encryption.py
"""
Field-level encryption for sensitive data at rest (national ID, phone numbers, etc.)
Uses Fernet (AES-128-CBC + HMAC) - symmetric, fast enough for per-field use.

Usage:
    encrypted = encrypt_field("1234567890")
    plain = decrypt_field(encrypted)

IMPORTANT: FIELD_ENCRYPTION_KEY in .env must be a valid Fernet key (44-char base64).
Generate one with:
    python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
Losing this key means losing access to all encrypted data - back it up securely
and separately from the database itself.
"""
from cryptography.fernet import Fernet, InvalidToken

from app.core.config import settings

_fernet = Fernet(settings.FIELD_ENCRYPTION_KEY.encode())


def encrypt_field(value):
    if value is None or value == "":
        return value
    return _fernet.encrypt(value.encode()).decode()


def decrypt_field(value):
    if value is None or value == "":
        return value
    try:
        return _fernet.decrypt(value.encode()).decode()
    except InvalidToken:
        return value


def search_hash(value):
    """هاش حتمي للبحث عن قيم مشفرة (الملاحظة 25 في تقرير الفحص).

    التشفير غير حتمي (IV عشوائي) فلا يمكن المقارنة على النص المشفر.
    هذا الهاش (HMAC-SHA256 بمفتاح SECRET_KEY) يسمح بفحص التكرار
    (مثل رقم الهوية) دون كشف القيمة الأصلية في قاعدة البيانات.
    """
    if value is None or value == "":
        return value
    import hashlib
    import hmac
    return hmac.new(
        settings.SECRET_KEY.encode(), str(value).encode(), hashlib.sha256
    ).hexdigest()
