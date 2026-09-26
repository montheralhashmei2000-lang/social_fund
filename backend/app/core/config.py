# app/core/config.py
"""
إعدادات التطبيق.

أمنياً: في ENV=production يُرفض إقلاع الخادم إذا بقيت SECRET_KEY أو
FIELD_ENCRYPTION_KEY على قيمهما الافتراضية (راجع validate_production_settings
والاستدعاء في app/main.py). هذه هي معالجة ملاحظتي الفحص 10 و11.
"""
from pydantic_settings import BaseSettings

_INSECURE_PREFIXES = ("CHANGE_ME",)
_FALLBACK_SECRET = "CHANGE_ME_TO_A_LONG_RANDOM_SECRET_IN_PRODUCTION"
_FALLBACK_FERNET = "CHANGE_ME_FERNET_KEY_44_CHARS_BASE64=="


class Settings(BaseSettings):
    APP_NAME: str = "Social Fund API"
    ENV: str = "development"

    DATABASE_URL: str = "postgresql://fund_user:fund_pass@localhost:5432/social_fund_db"

    # JWT - access token قصير الأجل (ساعة) ويُجدَّد عبر refresh token
    # قابل للإلغاء (جدول refresh_sessions) بدل 12 ساعة ثابتة سابقاً.
    SECRET_KEY: str = _FALLBACK_SECRET
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # مفتاح التشفير على مستوى الحقول (رقم الهوية، الهاتف، البريد).
    # توليد: python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
    # فقدان المفتاح = فقدان القدرة على فك البيانات المشفرة - احتفظ بنسخة احتياطية آمنة.
    FIELD_ENCRYPTION_KEY: str = _FALLBACK_FERNET

    # نطاقات CORS مفصولة بفواصل. مثال:
    #   CORS_ORIGINS=https://app.example.com,https://admin.example.com
    # لا تترك "*" في الإنتاج - راجع validate_production_settings.
    CORS_ORIGINS: str = "*"

    # Firebase Admin SDK - مسار ملف بيانات اعتماد الخدمة (خارج المشروع/النسخ).
    FIREBASE_CREDENTIALS_PATH: str = "firebase-service-account.json"

    # SMS (Twilio) - لإرسال رموز OTP حقيقية. اتركها فارغة في التطوير فقط
    # (يُطبع الرمز في الطرفية في وضع التطوير حصراً).
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_FROM_NUMBER: str = ""

    class Config:
        env_file = ".env"

    @property
    def cors_origins_list(self) -> list:
        raw = (self.CORS_ORIGINS or "").strip()
        if not raw or raw == "*":
            return ["*"]
        return [o.strip() for o in raw.split(",") if o.strip()]

    @property
    def is_production(self) -> bool:
        return (self.ENV or "").lower() == "production"


def validate_production_settings(env: str, secret_key: str, field_key: str, cors_origins: str) -> None:
    """يرفع RuntimeError إذا كانت إعدادات الإنتاج غير آمنة. يُستدعى عند إقلاع الخادم.

    معالجة مباشرة لنقطتي الفحص 10 و11: لم يعد بالإمكان تشغيل بيئة إنتاج
    بمفاتيح افتراضية أو CORS مفتوح بالكامل.
    """
    if (env or "").lower() != "production":
        return
    problems = []

    if not secret_key or secret_key.startswith(_INSECURE_PREFIXES) or len(secret_key) < 32:
        problems.append(
            'SECRET_KEY غير مضبوط أو أقصر من 32 حرفاً. ولّد مفتاحاً بـ: '
            'python -c "import secrets; print(secrets.token_urlsafe(48))"'
        )

    if not field_key or field_key.startswith(_INSECURE_PREFIXES):
        problems.append(
            'FIELD_ENCRYPTION_KEY غير مضبوط. ولّد مفتاحاً بـ: '
            'python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"'
        )
    else:
        try:
            from cryptography.fernet import Fernet
            Fernet(field_key.encode())
        except Exception:
            problems.append("FIELD_ENCRYPTION_KEY ليس مفتاح Fernet صالحاً")

    origins = [o.strip() for o in (cors_origins or "").split(",") if o.strip()]
    if "*" in origins or not origins:
        problems.append("CORS_ORIGINS يجب أن يحدد النطاقات الفعلية في الإنتاج (بدون *)")

    if problems:
        raise RuntimeError(
            "إعدادات الإنتاج غير آمنة - أصلح ما يلي قبل التشغيل:\n- " + "\n- ".join(problems)
        )


settings = Settings()
