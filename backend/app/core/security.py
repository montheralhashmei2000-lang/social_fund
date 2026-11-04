# app/core/security.py
from datetime import datetime, timedelta, timezone
import hashlib
import types
import uuid

from jose import jwt, JWTError

# توافق مع bcrypt 4.1+ : passlib 1.7.4 يقرأ الإصدار من bcrypt.__about__
# وهو خاصية أُزيلت في الإصدارات الحديثة، فيسقط كشف المحرك وي grapefruit.
try:  # pragma: no cover - يعتمد على إصدار bcrypt المثبّت
    import bcrypt as _bcrypt

    if not hasattr(_bcrypt, "__about__"):
        _bcrypt.__about__ = types.SimpleNamespace(__version__=_bcrypt.__version__)
except Exception:  # noqa: BLE001 - لا نُفشل التشغيل إن لم يكن bcrypt مثبتاً
    pass

from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password):
    return pwd_context.hash(password)


def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)


def hash_token(token: str) -> str:
    """بصمة SHA-256 لتخزين refresh tokens مجزّأة بدل نصها الصريح في قاعدة البيانات."""
    return hashlib.sha256(token.encode()).hexdigest()


def create_access_token(data, expires_minutes=None):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=expires_minutes or settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    # jti عشوائي يضمن تفرد كل token حتى لنفس المستخدم في نفس الثانية -
    # ضروري لتدوير refresh tokens وتخزينها مجزّأة.
    to_encode.update({"exp": expire, "type": "access", "jti": str(uuid.uuid4())})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(data):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh", "jti": str(uuid.uuid4())})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token):
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None
