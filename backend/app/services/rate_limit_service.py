# app/services/rate_limit_service.py
"""
حماية بسيطة من هجمات تخمين كلمات المرور (Brute Force) على /auth/login
و /auth/verify-otp.

يعمل هذا حالياً بالذاكرة (Python dict عادي) بنفس أسلوب otp_service.py -
مناسب لخادم واحد فقط. عند التوسع لأكثر من نسخة خادم، يجب استبداله بـ Redis
(نفس الملاحظة المذكورة في otp_service.py) حتى تُشارَك حالة المحاولات بين
كل النسخ بدل أن يحتفظ كل خادم بعدّاده الخاص.

القاعدة: نحسب المحاولات الفاشلة معاً حسب (عنوان IP + اسم المستخدم) خلال
نافذة زمنية متحركة. بعد تجاوز الحد، تُرفض المحاولات التالية برسالة توضح
مدة الانتظار المتبقية، حتى لو كانت بيانات الدخول صحيحة - هذا يمنع
الاستمرار في التخمين حتى لو "قارب" المهاجم على الرقم الصحيح.
"""
import time
from collections import defaultdict

MAX_ATTEMPTS = 5
WINDOW_SECONDS = 15 * 60
LOCKOUT_SECONDS = 15 * 60

_attempts = defaultdict(list)
_locked_until = {}


def _key(ip, username):
    return (ip or "unknown", username.lower().strip())


def check_allowed(ip, username):
    """يُستدعى قبل محاولة تسجيل الدخول. يُرجع (مسموح؟, ثوانٍ متبقية إن كان محظوراً)."""
    k = _key(ip, username)
    locked_until = _locked_until.get(k)
    if locked_until:
        remaining = int(locked_until - time.time())
        if remaining > 0:
            return False, remaining
        _locked_until.pop(k, None)
        _attempts.pop(k, None)
    return True, 0


def record_failure(ip, username):
    """يُستدعى بعد فشل محاولة تسجيل الدخول (بيانات خاطئة أو OTP خاطئ)."""
    k = _key(ip, username)
    now = time.time()

    recent = [t for t in _attempts[k] if now - t < WINDOW_SECONDS]
    recent.append(now)
    _attempts[k] = recent

    if len(recent) >= MAX_ATTEMPTS:
        _locked_until[k] = now + LOCKOUT_SECONDS


def record_success(ip, username):
    """يُستدعى بعد نجاح تسجيل الدخول - يصفّر عدّاد المحاولات."""
    k = _key(ip, username)
    _attempts.pop(k, None)
    _locked_until.pop(k, None)
