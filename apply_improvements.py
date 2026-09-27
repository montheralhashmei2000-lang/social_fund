#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
apply_improvements.py — ينفذ اقتراحات التطوير على نسخة المشروع دفعة واحدة.

الاستخدام:
    python apply_improvements.py            # من داخل مجلد SocialFund (جذر المشروع)
    python apply_improvements.py <مسار>     # أو مرر مسار الجذر

ما يفعله (كل خطوة آمنة للتكرار — تعيد التشغيل لا تكسر شيئاً):
  1. بيئة CI/CD: ينشئ .github/workflows/ci.yml (pytest + flutter analyze/test على كل push).
  2. قفل الإصدارات: يولد backend/requirements.lock من بيئتك الحالية (pip freeze)
     ويتأكد من وجود mobile_app/pubspec.lock (يشغل flutter pub get إن وجد flutter).
  3. الحد من المعدل الموزع: طبقة Redis اختيارية (REDIS_URL) مع تراجع تلقائي للذاكرة —
     تعداد المحاولات يصبح مشتركاً بين نسخ الخادم عند التوسع. (OTP مخزن في قاعدة
     البيانات أصلاً فيدير التعدد، والمرتبط بالذاكرة هو عداد المحاولات فقط).
  4. التحقق الميداني من بطاقة العضوية: نقطة نهاية /members/{id}/card-verify في الخادم
     + شاشة مسح QR في التطبيق (كاميرا) تعيد بيانات العضو وحالته — تُستخدم فعلياً
     عند الصرف بدل البطاقة المعروضة فقط، مع إذن CAMERA في أندرويد.
  5. إشعار الأعضاء بنتيجة طلباتهم: خدمة SMS (بوابة عامة SMS_GATEWAY_URL أو Twilio
     بنفس إعداد OTP) تستدعى آلياً عند كل تغيير حالة طلب مساعدة.
  6. الملخص التنفيذي: بطاقة أعلى لوحة المعلومات (صافي الخزينة، الطلبات المعلقة،
     الحملات النشطة بتقدمها) + زر التحقق الميداني المباشر منها.
"""
import shutil
import subprocess
import sys
from pathlib import Path

OK, SKIP, WARN, ERR = "[تم]", "[موجود مسبقاً]", "[تنبيه]", "[خطأ]"
results = []


def note(step, msg):
    results.append((step, msg))
    print(f"{step} {msg}")


# ============ 1) بيئة CI/CD ============

CI_YML = """# يعمل على كل push و pull request: اختبارات الخادم + فحص التطبيق
name: CI

on:
  push:
  pull_request:

jobs:
  backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - name: تثبيت الاعتماديات (الملف المقفول إن وجد)
        run: |
          if [ -f requirements.lock ]; then
            pip install -r requirements.lock
          else
            pip install -r requirements.txt
          fi
      - name: اختبارات pytest
        env:
          DATABASE_URL: sqlite:///:memory:
          SECRET_KEY: ci-secret-key
          FIELD_ENCRYPTION_KEY: zH5aGqYw6xVj8mQwB3nR2pL9sK4tN7cF1dE0uI6oA8s=
        run: python -m pytest -q

  mobile:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: mobile_app
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.24.3
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
"""


def step_ci(root: Path):
    target = root / ".github" / "workflows" / "ci.yml"
    if target.exists():
        note(SKIP, "1) CI: .github/workflows/ci.yml موجود مسبقاً")
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(CI_YML, encoding="utf-8")
    note(OK, "1) CI: أُنشئ .github/workflows/ci.yml (pytest + flutter على كل push)")


# ============ 2) قفل الإصدارات ============


def step_lock(root: Path):
    backend = root / "backend"
    lock = backend / "requirements.lock"
    try:
        out = subprocess.run(
            [sys.executable, "-m", "pip", "freeze", "--exclude-editable"],
            capture_output=True, text=True, timeout=180,
        )
        lines = [l for l in out.stdout.splitlines() if l.strip() and " @ " not in l]
        if out.returncode == 0 and lines:
            lock.write_text("\n".join(sorted(lines)) + "\n", encoding="utf-8")
            note(OK, f"2) قفل الإصدارات: وُلّد backend/requirements.lock ({len(lines)} حزمة) — أضفه للـgit")
        else:
            note(WARN, "2) قفل الإصدارات: pip freeze لم يعمل — شغّل يدوياً داخل بيئتك: pip freeze > backend/requirements.lock")
    except Exception as e:
        note(WARN, f"2) قفل الإصدارات: فشل التوليد ({e}) — ولّده يدوياً داخل بيئة الخادم")

    mobile = root / "mobile_app"
    if (mobile / "pubspec.lock").exists():
        note(SKIP, "2) قفل الإصدارات: mobile_app/pubspec.lock موجود — احرص على إضافته للـgit")
    elif shutil.which("flutter"):
        try:
            r = subprocess.run(["flutter", "pub", "get"], cwd=mobile, capture_output=True, text=True, timeout=300)
            if (mobile / "pubspec.lock").exists():
                note(OK, "2) قفل الإصدارات: وُلّد mobile_app/pubspec.lock (flutter pub get)")
            else:
                note(WARN, f"2) قفل الإصدارات: flutter pub get لم يكمل — شغّله يدوياً ({r.stderr[-120:]})")
        except Exception as e:
            note(WARN, f"2) قفل الإصدارات: تعذر تشغيل flutter ({e}) — شغّل flutter pub get يدوياً")
    else:
        note(WARN, "2) قفل الإصدارات: flutter غير موجود في PATH — شغّل flutter pub get داخل mobile_app")


# ============ 3) الحد من المعدل عبر Redis (اختياري) ============

DISTRIBUTED_LIMITS = '''# app/services/distributed_limits.py
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

logger = logging.getLogger("distributed_limits")

try:
    import redis  # pip install redis — يلزم فقط عند استخدام REDIS_URL
except ImportError:
    redis = None

_client = None
_backend = "memory"
if os.environ.get("REDIS_URL") and redis is not None:
    try:
        _client = redis.Redis.from_url(
            os.environ["REDIS_URL"], socket_connect_timeout=2, socket_timeout=2
        )
        _client.ping()
        _backend = "redis"
        logger.info("عدادات الحد من المعدل تعمل عبر Redis (مشتركة بين النسخ)")
    except Exception as e:  # redis غير متاح الآن — لا نسقط الخادم بسببه
        logger.warning("تعذر الاتصال بـ REDIS_URL (%s) — التراجع إلى وضع الذاكرة", e)
        _client = None
elif os.environ.get("REDIS_URL") and redis is None:
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
'''

RATE_LIMIT_NEW = '''# app/services/rate_limit_service.py
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
'''


def step_redis(root: Path):
    svc = root / "backend" / "app" / "services"
    svc.mkdir(parents=True, exist_ok=True)
    dl = svc / "distributed_limits.py"
    if dl.exists():
        note(SKIP, "3) Redis: distributed_limits.py موجود مسبقاً")
    else:
        dl.write_text(DISTRIBUTED_LIMITS, encoding="utf-8")
        note(OK, "3) Redis: أُنشئ app/services/distributed_limits.py")

    rl = svc / "rate_limit_service.py"
    if rl.exists() and "def reset_all" in rl.read_text(encoding="utf-8"):
        note(SKIP, "3) Redis: rate_limit_service.py محدّث مسبقاً")
    else:
        rl.write_text(RATE_LIMIT_NEW, encoding="utf-8")
        note(OK, "3) Redis: حُدّث rate_limit_service.py ليستخدم الطبقة الموزعة (تراجع تلقائي للذاكرة)")

    req = root / "backend" / "requirements-redis.txt"
    if not req.exists():
        req.write_text("redis>=4.6\n", encoding="utf-8")
        note(OK, "3) Redis: أُنشئ backend/requirements-redis.txt (ثبّته فقط عند استخدام REDIS_URL)")

    opt = root / "backend" / "app" / "services" / "otp_service.py"
    if opt.exists():
        note(SKIP, "3) Redis: OTP مخزن في قاعدة البيانات أصلاً (OtpCode) — يدير تعدد النسخ بدون تغيير")

    # توافق conftest: كان يلمس السمات الداخلية _attempts/_locked_until مباشرة
    conftest = root / "backend" / "tests" / "conftest.py"
    if conftest.exists():
        s = conftest.read_text(encoding="utf-8")
        if "rate_limit_service.reset_all()" not in s:
            s = s.replace("rate_limit_service._attempts.clear()", "rate_limit_service.reset_all()")
            s = s.replace("rate_limit_service._locked_until.clear()", "rate_limit_service.reset_all()")
            conftest.write_text(s, encoding="utf-8")
            note(OK, "3) Redis: حُدّث conftest ليستخدم reset_all() العام بدل السمات الداخلية")
        else:
            note(SKIP, "3) Redis: conftest محدّث مسبقاً")


# ============ 4) التحقق الميداني من بطاقة العضوية (QR) ============

CARD_VERIFY_ROUTER = '''# app/routers/card_verify.py
"""
التحقق الميداني من بطاقة العضوية: تُمسح بطاقة QR في التطبيق (عند صرف مساعدة
مثلاً) فيُستدعى هذا المسار ليعيد حالة العضوية الفعلية من الخادم — بدل أن
تبقى البطاقة عرضاً فقط. الإذن: أذون "aids" (من يصرف يتحقق).
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.member import Member
from app.models.user import User

router = APIRouter(prefix="/members", tags=["Card Verification"])


@router.get("/{member_id}/card-verify")
def verify_card(member_id: str, db: Session = Depends(get_db),
                user: User = Depends(require_permission("aids"))):
    m = db.query(Member).filter(Member.id == member_id, Member.deleted == False).first()  # noqa: E712
    if not m:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "العضو غير موجود - البطاقة غير صالحة")

    member_status = getattr(m, "status", None)
    is_active = member_status == "نشط" if member_status else bool(getattr(m, "is_active", True))
    return {
        "id": str(m.id),
        "name": m.name,
        "status": member_status or ("نشط" if is_active else "معلق"),
        "verified": is_active,
        "total_paid": getattr(m, "total_paid", 0) or 0,
        "balance_due": getattr(m, "balance_due", 0) or 0,
        "monthly_subscription": getattr(m, "monthly_subscription", 0) or 0,
    }
'''

CARD_SCAN_SCREEN = r"""import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/rbac.dart';
import '../services/api_service.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

/// التحقق الميداني من بطاقة عضوية: مسح QR البطاقة (SF-MEMBER:<id>)
/// والتحقق الفوري من الخادم — تُستخدم عند الصرف والتسليم الميداني.
class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key});

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  bool checking = false;
  bool resumed = true;

  Future<void> _verify(String memberId) async {
    if (checking) return;
    setState(() => checking = true);
    try {
      final r = await ApiService.instance.request('GET', '/members/$memberId/card-verify');
      final data = Map<String, dynamic>.from(r as Map);
      if (!mounted) return;
      await _showResult(data);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر التحقق - حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _showResult(Map<String, dynamic> m) async {
    final ok = m['verified'] == true;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(ok ? Icons.verified : Icons.gpp_bad, color: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C)),
          const SizedBox(width: 8),
          Text(ok ? 'بطاقة صالحة' : 'بطاقة غير صالحة', style: const TextStyle(fontSize: 17)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m['name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text('الحالة: ${m['status']}'),
            Text('المدفوع: ${money((m['total_paid'] as num?)?.toInt() ?? 0)}'),
            Text('المستحق: ${money((m['balance_due'] as num?)?.toInt() ?? 0)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
    if (mounted) setState(() => resumed = true); // السماح بمسح تالٍ
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final role = context.read<AuthController>().user?.role;
    if (!Rbac.can(role, 'aids')) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(title: const Text('تحقق ميداني'), backgroundColor: c.primaryDark),
        body: const EmptyState(icon: Icons.no_accounts, text: 'تحقق من البطاقات متاح لمن يملك صلاحية المساعدات'),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('تحقق من بطاقة عضوية'), backgroundColor: c.primaryDark),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!resumed || checking) return;
              for (final bar in capture.barcodes) {
                final v = bar.rawValue ?? '';
                if (v.startsWith('SF-MEMBER:')) {
                  setState(() { resumed = false; });
                  _verify(v.substring('SF-MEMBER:'.length));
                  break;
                }
              }
            },
          ),
          Positioned(
            left: 0, right: 0, bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: c.primaryDark.withOpacity(0.85), borderRadius: BorderRadius.circular(30)),
                child: Text(
                  checking ? 'جارٍ التحقق من الخادم…' : 'وجّه الكاميرا إلى بطاقة العضوية',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
"""


def step_qr(root: Path):
    backend = root / "backend"
    router_file = backend / "app" / "routers" / "card_verify.py"
    if router_file.exists():
        note(SKIP, "4) QR: نقطة نهاية card-verify موجودة مسبقاً")
    else:
        router_file.write_text(CARD_VERIFY_ROUTER, encoding="utf-8")
        note(OK, "4) QR: أُنشئ app/routers/card_verify.py (GET /members/{id}/card-verify)")

    main_py = backend / "app" / "main.py"
    s = main_py.read_text(encoding="utf-8")
    old_imp = "    accounts, journal, donors, campaigns, beneficiaries, inkind, budgets, reports_financial,\n)"
    if "card_verify" in s:
        note(SKIP, "4) QR: main.py مسجّل مسبقاً")
    elif old_imp in s:
        s = s.replace(old_imp, "    accounts, journal, donors, campaigns, beneficiaries, inkind, budgets, reports_financial,\n    card_verify,\n)")
        s = s.replace("app.include_router(reports_financial.router)",
                      "app.include_router(reports_financial.router)\napp.include_router(card_verify.router)")
        main_py.write_text(s, encoding="utf-8")
        note(OK, "4) QR: سُجّل الراوتر في main.py")
    else:
        note(ERR, "4) QR: لم أجد نقطة تسجيل الراوتر في main.py — سجّل card_verify يدوياً")

    # Flutter: مكتبة المسح + الشاشة + إذن الكاميرا
    pubspec = root / "mobile_app" / "pubspec.yaml"
    s = pubspec.read_text(encoding="utf-8")
    if "mobile_scanner" in s:
        note(SKIP, "4) QR: mobile_scanner مضاف مسبقاً في pubspec")
    elif "  qr_flutter: ^4.1.0" in s:
        s = s.replace("  qr_flutter: ^4.1.0", "  qr_flutter: ^4.1.0\n  mobile_scanner: ^5.0.0")
        pubspec.write_text(s, encoding="utf-8")
        note(OK, "4) QR: أُضيف mobile_scanner إلى pubspec.yaml")
    else:
        note(ERR, "4) QR: لم أجد مرساة qr_flutter في pubspec.yaml — أضف mobile_scanner: ^5.0.0 يدوياً")

    scan = root / "mobile_app" / "lib" / "screens" / "card_scan_screen.dart"
    if scan.exists():
        note(SKIP, "4) QR: شاشة المسح موجودة مسبقاً")
    else:
        scan.write_text(CARD_SCAN_SCREEN, encoding="utf-8")
        note(OK, "4) QR: أُنشئت lib/screens/card_scan_screen.dart (مسح كاميرا + تحقق من الخادم)")

    manifest = root / "mobile_app" / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
    if manifest.exists():
        s = manifest.read_text(encoding="utf-8")
        if "android.permission.CAMERA" in s:
            note(SKIP, "4) QR: إذن CAMERA موجود مسبقاً")
        elif "<application" in s:
            s = s.replace(
                "    <application",
                "    <uses-permission android:name=\"android.permission.CAMERA\"/>\n"
                "    <uses-feature android:name=\"android.hardware.camera\" android:required=\"false\"/>\n"
                "    <application",
                1,
            )
            manifest.write_text(s, encoding="utf-8")
            note(OK, "4) QR: أُضيف إذن CAMERA إلى AndroidManifest")
        else:
            note(ERR, "4) QR: لم أجد <application> في AndroidManifest — أضف إذن الكاميرا يدوياً")
    else:
        note(WARN, "4) QR: AndroidManifest غير موجود في المسار المتوقع")


# ============ 5) إشعار الأعضاء عبر SMS ============

SMS_SERVICE = '''# app/services/sms_service.py
"""
إشعار الأعضاء بنتيجة طلباتهم عبر قناة خارجية (الأعضاء لا يملكون حسابات دخول).

ترتيب المحاولات:
  1. بوابة HTTP عامة عند ضبط SMS_GATEWAY_URL (POST JSON: phone, message
     مع ترويسة Bearer إن ضُبط SMS_GATEWAY_TOKEN) — تصلح لأي مزود محلي.
  2. Twilio بنفس إعدادات OTP (TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN /
     TWILIO_FROM_NUMBER) عند توفرها.
  3. وإلا يُسجل النص في سجلات الخادم فقط (حتى تُعدّ بوابتك).
الفشل لا يُعطّل العملية الأصلية أبداً — يُسجل ويُكمل.
"""
import logging

import httpx
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.member import Member

logger = logging.getLogger("sms_service")


def _format_phone(phone: str) -> str:
    return phone if phone.startswith("+") else f"+967{phone.lstrip('0')}"


def send_sms(phone: str, message: str) -> str:
    """يعيد: gateway / twilio / logged / failed (للتوثيق في السجلات)."""
    if not phone:
        logger.info("SMS (لا رقم هاتف): %s", message)
        return "logged"
    try:
        if settings.SMS_GATEWAY_URL:
            headers = {"Authorization": f"Bearer {settings.SMS_GATEWAY_TOKEN}"} if getattr(settings, "SMS_GATEWAY_TOKEN", None) else {}
            resp = httpx.post(
                settings.SMS_GATEWAY_URL,
                json={"phone": _format_phone(phone), "message": message},
                headers=headers, timeout=10,
            )
            if resp.status_code < 300:
                return "gateway"
            logger.error("بوابة SMS رفضت الرسالة: %s", resp.status_code)
            return "failed"
    except Exception as e:
        logger.error("فشل إرسال SMS عبر البوابة: %s", e)
        return "failed"

    if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_FROM_NUMBER:
        try:
            from twilio.rest import Client
            Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN).messages.create(
                body=message, from_=settings.TWILIO_FROM_NUMBER, to=_format_phone(phone),
            )
            return "twilio"
        except Exception as e:
            logger.error("فشل إرسال SMS عبر Twilio: %s", e)
            return "failed"

    logger.info("SMS (لا بوابة مضبوطة) إلى %s: %s", phone, message)
    return "logged"


def notify_aid_status(db: Session, aid, old_status: str, new_status: str):
    """يُستدعى آلياً بعد كل تغيير حالة طلب مساعدة - يبلغ العضو بنتيجة طلبه."""
    member = db.query(Member).filter(Member.id == aid.member_id).first()
    message = (
        f"عزيزي {aid.member_name}، تم تحديث حالة طلب المساعدة ({aid.aid_type}) "
        f"من {old_status} إلى {new_status}. - الصندوق الاجتماعي التنموي"
    )
    outcome = send_sms(getattr(member, "phone", None) or "", message)
    logger.info("إشعار عضو عن طلب مساعدة: النتيجة=%s", outcome)
    return outcome
'''

AID_ANCHOR = "    db.commit()\n    db.refresh(aid)\n\n    # إشعار المدراء بالقرار المتخذ"
AID_INSERT = """    db.commit()
    db.refresh(aid)

    # إشعار العضو بنتيجة طلبه عبر قناة خارجية (SMS) - الأعضاء بلا حسابات دخول.
    try:
        from app.services.sms_service import notify_aid_status
        notify_aid_status(db, aid, old_status.value, new_status.value)
    except Exception:
        pass  # فشل الإشعار لا يعطل العملية الأصلية أبداً

    # إشعار المدراء بالقرار المتخذ"""


def step_sms(root: Path):
    svc = root / "backend" / "app" / "services" / "sms_service.py"
    if svc.exists():
        note(SKIP, "5) SMS: خدمة الإشعارات موجودة مسبقاً")
    else:
        svc.write_text(SMS_SERVICE, encoding="utf-8")
        note(OK, "5) SMS: أُنشئ app/services/sms_service.py (بوابة عامة أو Twilio)")

    aids = root / "backend" / "app" / "routers" / "aids.py"
    s = aids.read_text(encoding="utf-8")
    if "from app.services.sms_service import notify_aid_status" in s:
        note(SKIP, "5) SMS: ربط الإشعار بتغيّر الحالة موجود مسبقاً في aids.py")
    elif AID_ANCHOR in s:
        s = s.replace(AID_ANCHOR, AID_INSERT, 1)
        aids.write_text(s, encoding="utf-8")
        note(OK, "5) SMS: رُبط الإشعار آلياً بكل تغيير حالة طلب مساعدة")
    else:
        note(ERR, "5) SMS: لم أجد مرساة الربط في aids.py — استدعِ notify_aid_status بعد db.refresh")

    note(SKIP, "5) SMS: إعداد البوابة لاحقاً بضبط SMS_GATEWAY_URL (واختيارياً SMS_GATEWAY_TOKEN)")


# ============ 6) الملخص التنفيذي في لوحة المعلومات ============

EXEC_SUMMARY = r"""import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/rbac.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import '../screens/card_scan_screen.dart';

/// الملخص التنفيذي: صورة كاملة أعلى لوحة المعلومات — صافي الخزينة،
/// الطلبات المعلقة، الحملات النشطة بتقدمها، وزر التحقق الميداني من البطاقات.
class ExecutiveSummaryCard extends StatefulWidget {
  const ExecutiveSummaryCard({super.key});

  @override
  State<ExecutiveSummaryCard> createState() => _ExecutiveSummaryCardState();
}

class _ExecutiveSummaryCardState extends State<ExecutiveSummaryCard> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final exp = context.read<ExpansionController>();
      await exp.loadCampaigns();
      if (mounted) setState(() => loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final exp = context.watch<ExpansionController>();
    final role = context.read<AuthController>().user?.role;
    final active = exp.campaigns.where((x) => x.status != 'closed').take(3).toList();
    final net = data.treasuryBalance;

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 26, height: 3, color: c.gold),
              const SizedBox(width: 8),
              Expanded(child: Text('الملخص التنفيذي', style: AppTheme.sectionTitle(c, size: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _stat('صافي الخزينة', money(net), net >= 0 ? c.ok : c.err)),
              Expanded(child: _stat('طلبات معلقة', '${data.pendingAidsCount}', c.warn)),
              Expanded(child: _stat('حملات نشطة', '${active.length}', c.primary)),
            ],
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final camp in active)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(camp.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.tx)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: camp.percent.clamp(0.0, 100.0) / 100,
                              minHeight: 6, backgroundColor: c.surf, color: c.gold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${camp.percent}%',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: c.goldDark)),
                  ],
                ),
              ),
          ],
          if (Rbac.can(role, 'aids')) ...[
            const SizedBox(height: 6),
            UiButton(
              text: 'تحقق ميداني من بطاقة عضوية (مسح QR)',
              variant: 'gold',
              small: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardScanScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    final c = App.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        Text(label, style: TextStyle(fontSize: 10.5, color: c.mu)),
      ],
    );
  }
}
"""

DASH_ANCHOR = """        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _kpi(context, 'أعضاء نشطون',"""
DASH_NEW = """        const SizedBox(height: 14),
        const ExecutiveSummaryCard(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpi(context, 'أعضاء نشطون',"""


def step_exec(root: Path):
    widget = root / "mobile_app" / "lib" / "widgets" / "executive_summary.dart"
    if widget.exists():
        note(SKIP, "6) الملخص التنفيذي: البطاقة موجودة مسبقاً")
    else:
        widget.write_text(EXEC_SUMMARY, encoding="utf-8")
        note(OK, "6) الملخص التنفيذي: أُنشئت lib/widgets/executive_summary.dart")

    dash = root / "mobile_app" / "lib" / "screens" / "dashboard_screen.dart"
    s = dash.read_text(encoding="utf-8")
    changed = False
    if "executive_summary.dart" not in s:
        s = s.replace("import '../widgets/charts.dart';",
                      "import '../widgets/charts.dart';\nimport '../widgets/executive_summary.dart';", 1)
        changed = True
    if DASH_ANCHOR in s:
        s = s.replace(DASH_ANCHOR, DASH_NEW, 1)
        changed = True
        note(OK, "6) الملخص التنفيذي: أُدرجت البطاقة أعلى لوحة المعلومات")
    elif "ExecutiveSummaryCard()" in s:
        note(SKIP, "6) الملخص التنفيذي: مُدرجة مسبقاً في لوحة المعلومات")
    else:
        note(ERR, "6) الملخص التنفيذي: لم أجد مرساة الإدراج في dashboard_screen.dart")
    if changed:
        dash.write_text(s, encoding="utf-8")


# ============ تشغيل الكل ============


def main():
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).parent.resolve()
    # دعم التخطيطات الشائعة: مجلد SocialFund الفرعي أو مسار الأب مباشرة
    if (root / "SocialFund" / "backend" / "app").exists():
        root = root / "SocialFund"
    if not ((root / "backend" / "app").exists() and (root / "mobile_app" / "lib").exists()):
        print("ضع هذا السكريبت في جذر مجلد SocialFund (أو مرر المسار) ثم أعد التشغيل.")
        print(f"المسار الحالي: {root}")
        sys.exit(1)

    print(f"تطبيق اقتراحات التطوير على: {root}\n" + "=" * 60)
    for step in (step_ci, step_lock, step_redis, step_qr, step_sms, step_exec):
        try:
            step(root)
        except Exception as e:
            note(ERR, f"خطأ غير متوقع في {step.__name__}: {e}")

    print("=" * 60)
    print("\nالخطوات التالية:")
    print("  1) cd backend && python -m pytest -q          # تأكد أن كل الاختبارات خضراء")
    print("  2) cd mobile_app && flutter pub get && flutter analyze")
    print("  3) أضف للتتبع: .github/ backend/requirements.lock mobile_app/pubspec.lock")
    print("  4) عند التوسع لأكثر من خادم: REDIS_URL=... + pip install -r requirements-redis.txt")
    print("  5) لتفعيل إشعارات الأعضاء: SMS_GATEWAY_URL=... (أو إعدادات TWILIO_*)")
    print("  6) لرفع CI فعلياً: ارفع المشروع إلى GitHub — سيعمل تلقائياً على كل push")
    ok = sum(1 for s, _ in results if s == OK)
    skip = sum(1 for s, _ in results if s == SKIP)
    warn = sum(1 for s, _ in results if s == WARN)
    err = sum(1 for s, _ in results if s == ERR)
    print(f"\nالملخص: {ok} نُفذ | {skip} موجود مسبقاً | {warn} تنبيه | {err} خطأ")
    sys.exit(1 if err else 0)


if __name__ == "__main__":
    main()
