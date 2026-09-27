# app/services/rate_limit_service.py
"""
حماية من هجمات تخمين كلمات المرور على /auth/login و /auth/verify-otp.

تحسين: العدادات صارت عبر طبقة موزعة (distributed_limits) — Redis عند ضبط
REDIS_URL (تعداد مشترك بين نسخ الخادم خلف موازن الحمل)، ووضع الذاكرة
كما كان لخادم واحد. القاعدة نفسها: نحسب المحاولات الفاشلة معاً حسب
(عنوان IP + اسم المستخدم) خلال نافذة متحركة، وبعد تجاوز الحد يُحظر
المفتاح مدة كاملة حتى لو صحت بيانات الدخول.
"""
from app.services import distributed_limits

MAX_ATTEMPTS = 5
WINDOW_SECONDS = 15 * 60
LOCKOUT_SECONDS = 15 * 60


def _key(ip, username) -> str:
    return f"{ip or 'unknown'}:{(username or '').lower().strip()}"


def check_allowed(ip, username):
    """يُستدعى قبل محاولة تسجيل الدخول. يُرجع (مسموح؟, ثوانٍ متبقية إن كان محظوراً)."""
    return distributed_limits.check_allowed(_key(ip, username))


def record_failure(ip, username):
    """يُستدعى بعد فشل محاولة تسجيل الدخول (بيانات خاطئة أو OTP خاطئ)."""
    distributed_limits.record_failure(
        _key(ip, username), WINDOW_SECONDS, MAX_ATTEMPTS, LOCKOUT_SECONDS
    )


def record_success(ip, username):
    """يُستدعى بعد نجاح تسجيل الدخول - يصفّر عدّاد المحاولات."""
    distributed_limits.record_success(_key(ip, username))


def reset_all():
    """يصفّر كل العدادات — بديل آمن لما كان conftest يفعله بالسمات الداخلية."""
    distributed_limits.reset_all()
