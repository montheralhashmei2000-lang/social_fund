# app/services/distributed_limits.py
"""
طبقة تخزين موزعة لعدادات الحد من المعدل (Brute-Force):

- عند ضبط متغير البيئة REDIS_URL تصبح العدادات مشتركة بين كل نسخ الخادم
  خلف موازن الحمل (المشكلة الموثقة سابقاً: كل نسخة تحسب محاولاتها بمعزل).
- بدون REDIS_URL تعمل بالذاكرة كما كان (مناسب لخادم واحد) — لا حاجة
  لتثبيت مكتبة redis في وضع خادم واحد.
"""
import logging
import os
import time

from app.core.config import settings

logger = logging.getLogger("distributed_limits")

try:
    import redis  # pip install redis — يلزم فقط عند استخدام REDIS_URL
except ImportError:
    redis = None

_redis_url = settings.REDIS_URL or os.environ.get("REDIS_URL")
_client = None
_backend = "memory"
if _redis_url and redis is not None:
    try:
        _client = redis.Redis.from_url(
            _redis_url, socket_connect_timeout=2, socket_timeout=2
        )
        _client.ping()
        _backend = "redis"
        logger.info("عدادات الحد من المعدل تعمل عبر Redis (مشتركة بين النسخ)")
    except Exception as e:  # redis غير متاح الآن — لا نسقط الخادم بسببه
        logger.warning("تعذر الاتصال بـ REDIS_URL (%s) — التراجع إلى وضع الذاكرة", e)
        _client = None
elif _redis_url and redis is None:
    logger.warning("REDIS_URL مضبوط لكن مكتبة redis غير مثبتة (pip install redis) — وضع الذاكرة")

# ===== وضع الذاكرة =====
_memory_attempts: dict = {}
_memory_locks: dict = {}


def backend_name() -> str:
    return _backend


def _rkey(key: str) -> str:
    return f"rl:{key}"


def check_allowed(key: str):
    """(مسموح؟, ثوانٍ الحظر المتبقية)"""
    if _client is not None:
        remaining = _client.ttl(_rkey(key))
        if remaining is not None and remaining > 0:
            return False, int(remaining)
        return True, 0
    until = _memory_locks.get(key)
    if until:
        remaining = int(until - time.time())
        if remaining > 0:
            return False, remaining
        _memory_locks.pop(key, None)
        _memory_attempts.pop(key, None)
    return True, 0


def record_failure(key: str, window_seconds: int, max_attempts: int, lockout_seconds: int):
    now = time.time()
    if _client is not None:
        rk = _rkey(key)
        pipe = _client.pipeline()
        pipe.zremrangebyscore(rk, 0, now - window_seconds)
        pipe.zadd(rk, {str(now): now})
        pipe.zcard(rk)
        _, _, count = pipe.execute()
        if count >= max_attempts:
            _client.setex(_rkey(f"lock:{key}"), lockout_seconds, "1")
            _client.delete(rk)
        return
    recent = [t for t in _memory_attempts.get(key, []) if now - t < window_seconds]
    recent.append(now)
    _memory_attempts[key] = recent
    if len(recent) >= max_attempts:
        _memory_locks[key] = now + lockout_seconds


def record_success(key: str):
    if _client is not None:
        _client.delete(_rkey(key))
        _client.delete(_rkey(f"lock:{key}"))
        return
    _memory_attempts.pop(key, None)
    _memory_locks.pop(key, None)


def reset_all():
    """مسح كل العدادات والأقفال (تستدعيه الاختبارات بين الحالات)."""
    if _client is not None:
        for k in _client.scan_iter("rl:*"):
            _client.delete(k)
        return
    _memory_attempts.clear()
    _memory_locks.clear()
