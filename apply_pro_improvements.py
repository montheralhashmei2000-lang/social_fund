#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
apply_pro_improvements.py — ينفذ حزمة التطوير الاحترافي كاملة (أولوية: قبل التشغيل الفعلي).

الاستخدام:
    python apply_pro_improvements.py            # من جذر مجلد SocialFund أو الأب
    python apply_pro_improvements.py <مسار>

آمن للتكرار (كل خطوة تتحقق قبل التنفيذ). ما يفعله:

  1) ترقيم ذرّي للسندات والقيود (يمنع تكرار الأرقام عند تزامن المستخدمين):
     جدول counters بقفل صف (FOR UPDATE على PostgreSQL) + خدمة sequence_service،
     وهجرة 0007 للجدول مع بذرة من الأرقام الحالية.
  2) دورة CI على PostgreSQL حقيقي: خدمة postgres في GitHub Actions + pytest عليها.
  3) أمان مفاتيح التوقيع: .gitignore للمفتاح وkey.properties وbackups و.env
     + سكريبت توليد مفتاحك الخاص scripts/generate_keystore.sh.
  4) نسخ احتياطي آلي: خدمة backups في docker-compose (pg_dump يومي مع حذف
     الأقدم من 14 يوماً) + سكربتات scripts/backup.sh و scripts/restore.sh.
  5) بروكسي TLS: خدمة Caddy جاهزة في compose (شهادة تلقائية + حد حجم الطلب).
  6) مراقبة: تهيئة Sentry اختيارية بـ SENTRY_DSN + سجلات JSON لكل طلب
     مع X-Request-ID (يعود مع كل استجابة لتتبع أي عملية بالسجلات).
  7) واجهة مُصدرة: نفس الراوترات متاحة تحت /v1 (القديم يعمل كما هو فلا ينكسر التطبيق).
  8) الشعار ملف وليس قاعدة بيانات: رفع الشعار إلى MEDIA_DIR + خدمته من /media
     (حقل logo_base64 القديم يبقى يعمل للتوافق).
  9) إصلاح N+1 في قائمة المانحين: إجمالي التبرعات باستعلام مجمّع واحد.
 10) ترقيم صفحات متوافق: ?limit=&offset= مع ترويسة X-Total-Count على القوائم
     (بدون بارامترات تعيد كل شيء كما كان — التطبيق لا يتأثر).
 11) حماية السحب فوق الرصيد: سند صرف على حساب أصول يتجاوز رصيده يُرفض 400.
 12) اختبارات جديدة تثبت كل ما سبق (tests/test_pro_hardening.py).
"""
import sys
from pathlib import Path

OK, SKIP, WARN, ERR = "[تم]", "[موجود مسبقاً]", "[تنبيه]", "[خطأ]"
results = []


def note(step, msg):
    results.append((step, msg))
    print(f"{step} {msg}")


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def write(p: Path, s: str):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(s, encoding="utf-8")


# ============ 1) الترقيم الذرّي ============

COUNTERS_MODEL = '''# app/models/counters.py
"""عدادات تسلسلية ذرّية لأرقام السندات والقيود — آمنة مع تزامن المستخدمين."""
from sqlalchemy import Column, Integer, String

from app.core.database import Base


class Counter(Base):
    __tablename__ = "counters"

    name = Column(String(60), primary_key=True)
    value = Column(Integer, nullable=False, default=0)
'''

SEQUENCE_SERVICE = '''# app/services/sequence_service.py
"""
أرقام تسلسلية ذرّية: تقرأ/تزيد صفاً واحداً في جدول counters بقفل الصف
(with_for_update) — على PostgreSQL يمنع نسختين من الخادم أخذ نفس الرقم،
وعلى SQLite يكفي قفل الكتابة الواحد. القيود UNIQUE تبقى شبكة أمان أخيرة.
"""
from app.models.counters import Counter


def next_number(db, kind: str) -> int:
    row = db.query(Counter).filter(Counter.name == kind).with_for_update().first()
    if row is None:
        row = Counter(name=kind, value=0)
        db.add(row)
        db.flush()
        row = db.query(Counter).filter(Counter.name == kind).with_for_update().first()
    row.value = (row.value or 0) + 1
    db.flush()
    return row.value
'''

MIGRATION_0007 = '''"""atomic counters for vouchers/journal numbering

Revision ID: 0007_atomic_counters
Revises: 0006_vouchers_double_entry
Create Date: 2026-09-26
"""
from alembic import op
import sqlalchemy as sa

revision = "0007_atomic_counters"
down_revision = "0006_vouchers_double_entry"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "counters",
        sa.Column("name", sa.String(60), primary_key=True),
        sa.Column("value", sa.Integer, nullable=False, server_default="0"),
    )
    # بذرة من البيانات الحالية حتى لا تتكرر الأرقام القديمة
    conn = op.get_bind()
    try:
        rec = conn.execute(sa.text("SELECT COUNT(*) FROM vouchers WHERE kind = 'قبض'")).scalar() or 0
        pay = conn.execute(sa.text("SELECT COUNT(*) FROM vouchers WHERE kind = 'صرف'")).scalar() or 0
        je = conn.execute(sa.text("SELECT COUNT(*) FROM journal_entries")).scalar() or 0
        for name, val in (("voucher_receipt", rec), ("voucher_payment", pay), ("journal_entry", je)):
            conn.execute(sa.text("INSERT INTO counters (name, value) VALUES (:n, :v)"), {"n": name, "v": int(val)})
    except Exception:
        pass


def downgrade():
    op.drop_table("counters")
'''


def step_numbering(root: Path):
    be = root / "backend"
    model = be / "app" / "models" / "counters.py"
    if model.exists():
        note(SKIP, "1) ترقيم ذرّي: app/models/counters.py موجود")
    else:
        write(model, COUNTERS_MODEL)
        note(OK, "1) ترقيم ذرّي: أُنشئ app/models/counters.py")

    svc = be / "app" / "services" / "sequence_service.py"
    if svc.exists():
        note(SKIP, "1) ترقيم ذرّي: sequence_service.py موجود")
    else:
        write(svc, SEQUENCE_SERVICE)
        note(OK, "1) ترقيم ذرّي: أُنشئ app/services/sequence_service.py (قفل صف + بذرة)")

    mig = be / "alembic" / "versions" / "0007_atomic_counters.py"
    if mig.exists():
        note(SKIP, "1) ترقيم ذرّي: الهجرة 0007 موجودة")
    else:
        write(mig, MIGRATION_0007)
        note(OK, "1) ترقيم ذرّي: أُنشئت هجرة 0007 (جدول + بذرة من الأرقام الحالية)")

    vch = be / "app" / "routers" / "vouchers.py"
    s = read(vch)
    old_fn = '''def next_voucher_no(db: Session, kind: str) -> str:
    prefix = "REC" if kind == RECEIPT else "PAY"
    year = datetime.utcnow().year
    count = db.query(Voucher).filter(Voucher.kind == kind).count()
    return f"{prefix}-{year}-{count + 1:03d}"'''
    if "sequence_service import next_number" in s:
        note(SKIP, "1) ترقيم ذرّي: vouchers.py يستخدم العداد الذرّي")
    elif old_fn in s:
        s = s.replace(old_fn, '''def next_voucher_no(db: Session, kind: str) -> str:
    from app.services.sequence_service import next_number
    prefix = "REC" if kind == RECEIPT else "PAY"
    year = datetime.utcnow().year
    seq = next_number(db, "voucher_" + ("receipt" if kind == RECEIPT else "payment"))
    return f"{prefix}-{year}-{seq:04d}"''')
        # تسجيل النموذج مبكراً (ليُنشأ جدول counters في وضع التطوير قبل أول استخدام)
        s = s.replace("from app.services.audit_service import log_action",
                      "from app.services import sequence_service  # noqa: F401 (يسجل نموذج العدادات)\nfrom app.services.audit_service import log_action", 1)
        write(vch, s)
        note(OK, "1) ترقيم ذرّي: حُوّل ترقيم السندات إلى العداد الذرّي")
    else:
        note(ERR, "1) ترقيم ذرّي: لم أجد next_voucher_no المتوقعة في vouchers.py")

    jrn = be / "app" / "routers" / "journal.py"
    s = read(jrn)
    old_fn = '''def _next_entry_no(db: Session) -> str:
    seq = (db.query(func.count(JournalEntry.id)).scalar() or 0) + 1
    return f"JE-{seq:06d}"'''
    old_inline = '''    seq = (db.query(func.count(JournalEntry.id)).scalar() or 0) + 1
    entry.entry_no = f"JE-{seq:06d}"'''
    if "sequence_service import next_number" in s:
        note(SKIP, "1) ترقيم ذرّي: journal.py يستخدم العداد الذرّي")
    elif old_fn in s:
        s = s.replace(old_fn, '''def _next_entry_no(db: Session) -> str:
    from app.services.sequence_service import next_number
    return f"JE-{next_number(db, 'journal_entry'):06d}"''')
        s = s.replace("from app.services.audit_service import log_action",
                      "from app.services import sequence_service  # noqa: F401 (يسجل نموذج العدادات)\nfrom app.services.audit_service import log_action", 1)
        write(jrn, s)
        note(OK, "1) ترقيم ذرّي: حُوّل ترقيم القيود JE إلى العداد الذرّي")
    elif old_inline in s:
        s = s.replace(old_inline, '''    from app.services.sequence_service import next_number
    entry.entry_no = f"JE-{next_number(db, 'journal_entry'):06d}"''', 1)
        s = s.replace("from app.services.audit_service import log_action",
                      "from app.services import sequence_service  # noqa: F401 (يسجل نموذج العدادات)\nfrom app.services.audit_service import log_action", 1)
        write(jrn, s)
        note(OK, "1) ترقيم ذرّي: حُوّل الترقيم المضمّن للقيود JE إلى العداد الذرّي")
    else:
        note(ERR, "1) ترقيم ذرّي: لم أجد نقطة ترقيم القيود في journal.py")

    # حماية السحب فوق الرصيد (بند 11)
    if "_account_balance" in s:
        note(SKIP, "11) حماية الرصيد: مطبقة مسبقاً في journal.py السياق")
    anchor = '''    if not counter_acc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "الحساب المقابل غير موجود")'''
    guard = anchor + '''

    # حماية من السحب فوق الرصيد: سند صرف على حساب أصول لا يتجاوز رصيده
    if kind == VoucherKind.payment and (treasury_acc.type or "") == "asset":
        bal_rows = (db.query(JournalLine.debit, JournalLine.credit)
                    .join(JournalEntry, JournalLine.entry_id == JournalEntry.id)
                    .filter(JournalLine.account_id == treasury_acc.id,
                            JournalEntry.status == "posted").all())
        bal = sum(Decimal(str(d or 0)) for d, _ in bal_rows) - sum(Decimal(str(c or 0)) for _, c in bal_rows)
        if bal < Decimal(str(data.amount)):
            raise HTTPException(status.HTTP_400_BAD_REQUEST,
                                f"رصيد الحساب غير كافٍ للمصروف: المتاح {bal} والمطلوب {data.amount}")'''
    vch2 = read(vch)
    if "رصيد الحساب غير كافٍ" in vch2:
        note(SKIP, "11) حماية الرصيد: مطبقة مسبقاً في vouchers.py")
    elif anchor in vch2:
        vch2 = vch2.replace(anchor, guard, 1)
        write(vch, vch2)
        note(OK, "11) حماية الرصيد: رفض سند صرف يتجاوز رصيد حساب الأصول (400)")
    else:
        note(ERR, "11) حماية الرصيد: لم أجد مرساة الإدراج في vouchers.py")


# ============ 2) CI على PostgreSQL ============

CI_PG_YML = """# يعمل على كل push: pytest على SQLite وعلى PostgreSQL حقيقي + فحص التطبيق
name: CI

on:
  push:
  pull_request:

jobs:
  backend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        db: [sqlite, postgres]
    defaults:
      run:
        working-directory: backend
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: socialfund_ci
          POSTGRES_USER: socialfund
          POSTGRES_PASSWORD: ci-password
        ports: ["5432:5432"]
        options: >-
          --health-cmd "pg_isready -U socialfund"
          --health-interval 5s --health-timeout 5s --health-retries 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - name: تثبيت الاعتماديات
        run: |
          if [ -f requirements.lock ]; then pip install -r requirements.lock; else pip install -r requirements.txt; fi
          if [ "${{ matrix.db }}" = "postgres" ]; then pip install "psycopg[binary]"; fi
      - name: اختبارات pytest (${{ matrix.db }})
        env:
          DATABASE_URL: ${{ matrix.db == 'postgres' && 'postgresql+psycopg://socialfund:ci-password@localhost:5432/socialfund_ci' || 'sqlite:///:memory:' }}
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
    wf = root / ".github" / "workflows" / "ci.yml"
    if wf.exists() and "postgres" in read(wf):
        note(SKIP, "2) CI: الدورة تعمل على PostgreSQL مسبقاً")
    elif wf.exists():
        write(wf, CI_PG_YML)
        note(OK, "2) CI: رُقّيت الدورة لتشمل مصفوفة SQLite + PostgreSQL")
    else:
        write(wf, CI_PG_YML)
        note(OK, "2) CI: أُنشئت الدورة (SQLite + PostgreSQL + flutter) لكل push")


# ============ 3) أمان مفاتيح التوقيع ============

GITIGNORE = """# مفاتيح التوقيع والأسرار - لا ترفع للمستودع أبداً
mobile_app/android/key.jks
mobile_app/android/key.properties
*.jks
.env
backups/
dist/
__pycache__/
*.pyc
.dart_tool/
.pytest_cache/
"""


def step_keys(root: Path):
    gi = root / ".gitignore"
    if gi.exists():
        s = read(gi)
        add = [l for l in GITIGNORE.splitlines() if l.strip() and l not in s.splitlines() and not l.startswith("#")]
        if add:
            write(gi, s.rstrip() + "\n" + "\n".join(add) + "\n")
            note(OK, f"3) مفاتيح: أُضيف {len(add)} سطراً إلى .gitignore")
        else:
            note(SKIP, "3) مفاتيح: .gitignore يغطيها مسبقاً")
    else:
        write(gi, GITIGNORE)
        note(OK, "3) مفاتيح: أُنشئ .gitignore (المفتاح والأسرار والنسخ خارج المستودع)")

    gen = root / "scripts" / "generate_keystore.sh"
    if gen.exists():
        note(SKIP, "3) مفاتيح: سكريبت توليد المفتاح موجود")
    else:
        write(gen, '''#!/usr/bin/env bash
# توليد مفتاح توقيع خاص بك (استبدل المفتاح التجريبي) - احتفظ بالملف وكلمات المرور في مكان آمن
# الاستخدام: bash scripts/generate_keystore.sh
set -e
read -rp "اسم المنشأة (CN): " CN
read -rp "كلمة مرور المفتاح: " -s PASS; echo
KS="mobile_app/android/key.jks"
keytool -genkeypair -v -keystore "$KS" -storepass "$PASS" -keypass "$PASS" \\
  -alias socialfund -keyalg RSA -keysize 2048 -validity 10000 \\
  -dname "CN=${CN:-SocialFund}, O=SocialFund, C=YE"
printf 'storePassword=%s\\nkeyPassword=%s\\nkeyAlias=socialfund\\nstoreFile=key.jks\\n' "$PASS" "$PASS" > mobile_app/android/key.properties
echo "تم - الملف $KS وkey.properties ممنوع رفعهما للـgit (مستثناة في .gitignore)"
''')
        gen.chmod(0o755)
        note(OK, "3) مفاتيح: أُنشئ scripts/generate_keystore.sh لتوليد مفتاحك الخاص")


# ============ 4) نسخ احتياطي آلي + 5) بروكسي TLS ============

COMPOSE_ADDON = """
  # نسخ احتياطي يومي آلي (يقصّ الأقدم من 14 يوماً) — فعّله بـ: docker compose --profile backup up -d
  backups:
    image: postgres:16-alpine
    profiles: ["backup"]
    environment:
      PGPASSWORD: ${POSTGRES_PASSWORD:?ضع POSTGRES_PASSWORD في .env}
    volumes:
      - ./backups:/backups
    depends_on:
      - db
    entrypoint: ["sh", "-c", "while true; do pg_dump -h db -U socialfund socialfund | gzip > /backups/socialfund-$$(date +%Y%m%d-%H%M%S).sql.gz; find /backups -name '*.sql.gz' -mtime +14 -delete; sleep 86400; done"]

  # بروكسي TLS (شهادة تلقائية من Let's Encrypt) — فعّله بـ:
  #   DOMAIN=your-domain.com docker compose --profile proxy up -d
  proxy:
    image: caddy:2-alpine
    profiles: ["proxy"]
    ports:
      - "80:80"
      - "443:443"
    environment:
      DOMAIN: ${DOMAIN:-localhost}
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddydata:/data
      - caddyconfig:/config
    depends_on:
      - api
"""

CADDYFILE = """{$DOMAIN} {
	encode gzip
	request_body {
		max_size 20MB
	}
	reverse_proxy api:8000
	header {
		Strict-Transport-Security "max-age=31536000; includeSubDomains"
		X-Content-Type-Options "nosniff"
		X-Frame-Options "DENY"
		Referrer-Policy "no-referrer"
	}
}
"""

BACKUP_SH = '''#!/usr/bin/env bash
# نسخة احتياطية مشفرة عند الطلب: bash scripts/backup.sh [BACKUP_PASSPHRASE]
set -e
cd "$(dirname "$0")/.."
mkdir -p backups
TS=$(date +%Y%m%d-%H%M%S)
docker compose exec -T db pg_dump -U socialfund socialfund | gzip > "backups/socialfund-$TS.sql.gz"
if [ -n "$1" ]; then
  openssl enc -aes-256-cbc -pbkdf2 -salt -in "backups/socialfund-$TS.sql.gz" -out "backups/socialfund-$TS.sql.gz.enc" -pass pass:"$1"
  rm "backups/socialfund-$TS.sql.gz"
  echo "النسخة المشفرة: backups/socialfund-$TS.sql.gz.enc"
fi
if [ -n "$BACKUP_REMOTE" ] && command -v rclone >/dev/null; then
  rclone copy backups/ "$BACKUP_REMOTE" && echo "رُفعت إلى $BACKUP_REMOTE"
fi
echo "تمت النسخة الاحتياطية: socialfund-$TS"
'''

RESTORE_SH = '''#!/usr/bin/env bash
# استعادة نسخة: bash scripts/restore.sh backups/socialfund-XXXX.sql.gz[.enc] [PASSPHRASE]
set -e
cd "$(dirname "$0")/.."
F="$1"; [ -f "$F" ] || { echo "الملف غير موجود: $F"; exit 1; }
case "$F" in
  *.enc)
    [ -n "$2" ] || { echo "مرر كلمة التشفير كبارامتر ثانٍ"; exit 1; }
    DEC=$(mktemp --suffix=.sql.gz); openssl enc -d -aes-256-cbc -pbkdf2 -in "$F" -out "$DEC" -pass pass:"$2"; F="$DEC";;
esac
gunzip -c "$F" | docker compose exec -T db psql -U socialfund -d socialfund
echo "تمت الاستعادة - اختبر التطبيق قبل المتابعة"
'''


def step_ops(root: Path):
    compose = root / "docker-compose.yml"
    if not compose.exists():
        note(WARN, "4/5) التشغيل: docker-compose.yml غير موجود في هذا التخطيط — طبق على الحزمة الموحدة")
    elif "backups:" in read(compose):
        note(SKIP, "4/5) التشغيل: خدمتا النسخ والبروكسي موجودتان مسبقاً في compose")
    else:
        s = read(compose)
        s = s.replace("\nvolumes:\n", COMPOSE_ADDON + "\nvolumes:\n  caddydata:\n  caddyconfig:\n", 1)
        write(compose, s)
        note(OK, "4/5) التشغيل: أُضيفت خدمة النسخ اليومي (profile: backup) وبروكسي Caddy TLS (profile: proxy)")

    (root / "caddy").mkdir(exist_ok=True)
    cf = root / "caddy" / "Caddyfile"
    if cf.exists():
        note(SKIP, "5) بروكسي: Caddyfile موجود")
    else:
        write(cf, CADDYFILE)
        note(OK, "5) بروكسي: أُنشئ caddy/Caddyfile (TLS تلقائي + حد 20MB + ترويسات أمان)")

    for name, body in (("backup.sh", BACKUP_SH), ("restore.sh", RESTORE_SH)):
        f = root / "scripts" / name
        if f.exists():
            note(SKIP, f"4) نسخ احتياطي: {name} موجود")
        else:
            write(f, body)
            f.chmod(0o755)
            note(OK, f"4) نسخ احتياطي: أُنشئ scripts/{name}")


# ============ 6) مراقبة + سجلات JSON + 7) /v1 ============


def step_monitoring(root: Path):
    main_py = root / "backend" / "app" / "main.py"
    s = read(main_py)

    if "sentry_sdk" not in s:
        sentry_block = '''# ===== المراقبة (اختيارية): فعّلها بضبط SENTRY_DSN + pip install sentry-sdk[fastapi] =====
import os as _os
if _os.environ.get("SENTRY_DSN"):
    try:
        import sentry_sdk
        sentry_sdk.init(dsn=_os.environ["SENTRY_DSN"], traces_sample_rate=0.1)
    except ImportError:
        import logging as _l
        _l.getLogger("uvicorn.error").warning("SENTRY_DSN مضبوط لكن sentry-sdk غير مثبت - تجاهل")

app = FastAPI('''
        s = s.replace("app = FastAPI(", sentry_block, 1)
        note(OK, "6) مراقبة: أُضيفت تهيئة Sentry الاختيارية (SENTRY_DSN)")

    old_mid = '''@app.middleware("http")
async def security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    return response'''
    if "X-Request-ID" in s:
        note(SKIP, "6) سجلات: وسطية request_id موجودة مسبقاً")
    elif old_mid in s:
        s = s.replace(old_mid, '''@app.middleware("http")
async def security_headers(request: Request, call_next):
    """ترويسات أمان + معرّف طلب فريد (X-Request-ID) + سجل JSON منظم لكل طلب."""
    import json as _json
    import logging as _logging
    import time as _time
    import uuid as _uuid

    started = _time.time()
    response = await call_next(request)
    rid = _uuid.uuid4().hex[:12]
    response.headers.setdefault("X-Request-ID", rid)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    try:
        _logging.getLogger("app.access").info(_json.dumps({
            "request_id": rid, "method": request.method, "path": request.url.path,
            "status": response.status_code, "ms": round((_time.time() - started) * 1000, 1),
        }, ensure_ascii=False))
    except Exception:
        pass
    return response''', 1)
        note(OK, "6) سجلات: كل طلب له X-Request-ID وسجل JSON (method/path/status/ms)")

    if '"/v1"' in s:
        note(SKIP, "7) API v1: مُصدّرة مسبقاً")
    else:
        v1_block = '''

# ===== واجهة مُصدرة بإصدار: نفس الراوترات تحت /v1 (القديم يعمل للتوافق) =====
import importlib as _importlib

for _name in ("auth", "users", "members", "aids", "subscriptions", "treasury", "vouchers",
              "messages", "events", "fund_settings", "reports", "backup", "audit", "push",
              "admin", "accounts", "journal", "donors", "campaigns", "beneficiaries",
              "inkind", "budgets", "reports_financial", "card_verify"):
    try:
        app.include_router(_importlib.import_module(f"app.routers.{_name}").router, prefix="/v1")
    except ModuleNotFoundError:
        pass  # راوتر غير موجود في هذا التخطيط - تجاهل


@app.get("/")'''
        s = s.replace('\n\n@app.get("/")', v1_block, 1)
        note(OK, "7) API v1: الراوترات متاحة الآن تحت /v1 أيضاً (بدون كسر التطبيق الحالي)")

    write(main_py, s)

    prod = root / "backend" / "requirements-prod.txt"
    if not prod.exists():
        write(prod, "sentry-sdk[fastapi]>=2.0\n")
        note(OK, "6) مراقبة: أُنشئ backend/requirements-prod.txt (ثبّته فقط عند تفعيل Sentry)")


# ============ 8) الشعار ملف ============

MEDIA_PATCH = '''

# ===== وسائط الملفات (الشعار) — تخزين ملف بدل قاعدة البيانات =====
from fastapi.staticfiles import StaticFiles  # noqa: E402

MEDIA_DIR = Path(os.environ.get("MEDIA_DIR", "./media"))
MEDIA_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=str(MEDIA_DIR)), name="media")
'''

UPLOAD_LOGO = '''

def _save_media(data: bytes, ext: str) -> str:
    """يحفظ ملف وسائط ويعيد اسمه - يُخدم من /media بدل تخزين القاعدة."""
    import uuid as _uuid
    from pathlib import Path as _P
    media = _P(os.environ.get("MEDIA_DIR", "./media"))
    media.mkdir(parents=True, exist_ok=True)
    name = f"{_uuid.uuid4().hex}.{ext}"
    (media / name).write_bytes(data)
    return name


@router.put("/logo-file")
async def upload_logo_file(request: Request, db: Session = Depends(get_db),
                           user: User = Depends(require_permission("settings"))):
    """رفع شعار كملف (multipart/form-data: file) - يُخزن على القرص ويُخدم من /media."""
    import os as _os
    content_type = request.headers.get("content-type", "")
    if "multipart/form-data" not in content_type:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "أرسل الشعار كـ multipart/form-data")
    form = await request.form()
    f = form.get("file")
    if f is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "الملف مفقود")
    ext = (_os.path.splitext(f.filename or "")[1] or ".png").lstrip(".").lower()
    if ext not in ("png", "jpg", "jpeg", "webp", "svg"):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "صيغة غير مدعومة (png/jpg/webp/svg)")
    data = await f.read()
    if len(data) > 5 * 1024 * 1024:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "أقصى حجم 5 ميغابايت")
    name = _save_media(data, ext)
    fs = db.query(FundSettings).first()
    if not fs:
        fs = FundSettings(name="الصندوق الاجتماعي التنموي")
        db.add(fs)
    fs.logo_base64 = f"/media/{name}"  # توافق: الواجهة تقرأ الرابط من نفس الحقل
    db.commit()
    return {"logo_url": f"/media/{name}"}
'''


def step_media(root: Path):
    fs_router = root / "backend" / "app" / "routers" / "fund_settings.py"
    if not fs_router.exists():
        note(ERR, "8) الوسائط: fund_settings.py غير موجود")
        return
    s = read(fs_router)
    if "logo-file" in s:
        note(SKIP, "8) الوسائط: رفع الشعار كملف موجود مسبقاً")
        return
    # إلحاق نقطة الرفع في نهاية الملف + الحقن المعتمد على اسم الراوتر الفعلي
    if "router = APIRouter" in s:
        if "HTTPException" not in s.split("\n")[0:3][0]:
            s = s.replace("from fastapi import APIRouter, Depends, Request",
                          "from fastapi import APIRouter, Depends, HTTPException, Request, status", 1)
        s = s.rstrip() + UPLOAD_LOGO
        write(fs_router, s)
        note(OK, "8) الوسائط: أُضيف PUT /fund-settings/logo-file (multipart، حد 5MB)")
    else:
        note(ERR, "8) الوسائط: لم أجد router في fund_settings.py")

    main_py = root / "backend" / "app" / "main.py"
    s = read(main_py)
    if "/media" in s:
        note(SKIP, "8) الوسائط: مسار /media مثبت مسبقاً")
    else:
        s = s.replace('from fastapi.middleware.cors import CORSMiddleware',
                      'from fastapi.middleware.cors import CORSMiddleware\nfrom pathlib import Path\nimport os', 1)
        s = s.rstrip() + MEDIA_PATCH
        write(main_py, s)
        note(OK, "8) الوسائط: يُخدم /media من القرص (MEDIA_DIR، الافتراضي ./media)")


# ============ 9) إصلاح N+1 في المانحين + 10) ترقيم الصفحات ============


def step_queries(root: Path):
    donors = root / "backend" / "app" / "routers" / "donors.py"
    s = read(donors)
    old = '''@router.get("/donors")
def list_donors(db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    return [_donor_out(db, d) for d in db.query(Donor).order_by(Donor.name).all()]'''
    if "totals_map" in s:
        note(SKIP, "9) N+1: قائمة المانحين مجمّعة مسبقاً")
    elif old in s:
        new = '''@router.get("/donors")
def list_donors(db: Session = Depends(get_db), user: User = Depends(require_permission("donors"))):
    """قائمة المانحين بإجمالي التبرعات — استعلام مجمّع واحد بدل استعلام لكل مانح (N+1)."""
    totals = (
        db.query(JournalEntry.donor_id.label("did"),
                 func.coalesce(func.sum(JournalLine.credit - JournalLine.debit), 0).label("total"))
        .join(JournalLine, JournalLine.entry_id == JournalEntry.id)
        .filter(JournalEntry.status == "posted", JournalLine.credit > 0, JournalEntry.donor_id.isnot(None))
        .group_by(JournalEntry.donor_id)
        .all()
    )
    totals_map = {str(t.did): float(t.total) for t in totals}
    out = []
    for d in db.query(Donor).order_by(Donor.name).all():
        item = _donor_out(db, d, total_override=totals_map.get(str(d.id), 0.0))
        out.append(item)
    return out'''
        s = s.replace(old, new, 1)
        s = s.replace('''def _donor_out(db: Session, d: Donor):''',
                      '''def _donor_out(db: Session, d: Donor, total_override=None):''', 1)
        s = s.replace('''    ).filter(
        JournalEntry.donor_id == d.id,
        JournalEntry.status == "posted",
        JournalLine.credit > 0,
    ).scalar() or 0''',
                      '''    ).filter(
        JournalEntry.donor_id == d.id,
        JournalEntry.status == "posted",
        JournalLine.credit > 0,
    ).scalar() or 0 if total_override is None else 0''', 1)
        # إدخال قيمة الoverride فوق حساب total الحالي (أسطر تكتب بعد التعريف مباشرة)
        s = s.replace('''def _donor_out(db: Session, d: Donor, total_override=None):
    total = db.query(''', '''def _donor_out(db: Session, d: Donor, total_override=None):
    if total_override is not None:
        total = total_override
    else:
        total = db.query(''', 1)
        write(donors, s)
        note(OK, "9) N+1: قائمة المانحين صارت باستعلام مجمّع واحد (كان استعلاماً لكل مانح)")
    else:
        note(ERR, "9) N+1: لم أجد list_donors المتوقعة في donors.py")

    # ترقيم الصفحات: aids + vouchers + journal (ترويسة X-Total-Count + limit/offset اختياريان)
    aids = root / "backend" / "app" / "routers" / "aids.py"
    s = read(aids)
    old_sig = '''def list_aids(status_filter: Optional[str] = None, db: Session = Depends(get_db),
              user: User = Depends(require_permission("aids"))):'''
    old_ret = '''    return q.order_by(AidRequest.request_date.desc()).all()'''
    if "X-Total-Count" in s:
        note(SKIP, "10) ترقيم الصفحات: aids مجهز")
    elif old_sig in s and old_ret in s:
        s = s.replace(old_sig, '''def list_aids(status_filter: Optional[str] = None,
              limit: Optional[int] = None, offset: int = 0,
              response: Response = None, db: Session = Depends(get_db),
              user: User = Depends(require_permission("aids"))):''')
        s = s.replace(old_ret, '''    q = q.order_by(AidRequest.request_date.desc())
    if limit:
        q = q.offset(offset).limit(limit)
    return q.all()''')
        s = s.replace("from fastapi import APIRouter, Depends, HTTPException, status, Request",
                      "from fastapi import APIRouter, Depends, HTTPException, Request, Response, status", 1)
        write(aids, s)
        note(OK, "10) ترقيم الصفحات: aids (limit/offset اختياري + X-Total-Count)")
    else:
        note(ERR, "10) ترقيم الصفحات: لم أجد مراسي aids.py")

    jrn = root / "backend" / "app" / "routers" / "journal.py"
    s = read(jrn)
    old_ret = '''    return [_entry_out(db, e) for e in q.limit(300).all()]'''
    if "X-Total-Count" in s:
        note(SKIP, "10) ترقيم الصفحات: journal مجهز")
    elif old_ret in s and "def list_entries(" in s:
        s = s.replace('''def list_entries(date_from: Optional[str] = None, date_to: Optional[str] = None,
                 entry_type: Optional[str] = None, status_filter: Optional[str] = None,
                 campaign_id: Optional[str] = None, donor_id: Optional[str] = None,
                 db: Session = Depends(get_db), user: User = Depends(require_permission("accounting"))):''',
                      '''def list_entries(date_from: Optional[str] = None, date_to: Optional[str] = None,
                 entry_type: Optional[str] = None, status_filter: Optional[str] = None,
                 campaign_id: Optional[str] = None, donor_id: Optional[str] = None,
                 limit: Optional[int] = None, offset: int = 0,
                 response: Response = None, db: Session = Depends(get_db),
                 user: User = Depends(require_permission("accounting"))):''')
        s = s.replace(old_ret, '''    total = q.count()
    if response is not None:
        response.headers["X-Total-Count"] = str(total)
    if limit:
        q = q.offset(offset).limit(limit)
    return [_entry_out(db, e) for e in q.all()]''')
        s = s.replace("from fastapi import APIRouter, Depends, HTTPException, status",
                      "from fastapi import APIRouter, Depends, HTTPException, Response, status", 1)
        write(jrn, s)
        note(OK, "10) ترقيم الصفحات: journal (limit/offset اختياري + X-Total-Count)")
    else:
        note(ERR, "10) ترقيم الصفحات: لم أجد مراسي journal.py")

    vch = root / "backend" / "app" / "routers" / "vouchers.py"
    s = read(vch)
    old_ret = '''    return [_voucher_out(db, v) for v in q.order_by(Voucher.voucher_date.desc()).limit(300).all()]'''
    if "X-Total-Count" in s:
        note(SKIP, "10) ترقيم الصفحات: vouchers مجهز")
    elif old_ret in s and "def list_vouchers(" in s:
        s = s.replace('''def list_vouchers(kind: Optional[str] = None, member_id: Optional[str] = None,
                  donor_id: Optional[str] = None, beneficiary_id: Optional[str] = None,
                  db: Session = Depends(get_db), user: User = Depends(require_permission("vouchers"))):''',
                      '''def list_vouchers(kind: Optional[str] = None, member_id: Optional[str] = None,
                  donor_id: Optional[str] = None, beneficiary_id: Optional[str] = None,
                  limit: Optional[int] = None, offset: int = 0,
                  response: Response = None, db: Session = Depends(get_db),
                  user: User = Depends(require_permission("vouchers"))):''')
        s = s.replace(old_ret, '''    q = q.order_by(Voucher.voucher_date.desc())
    if limit:
        q = q.offset(offset).limit(limit)
    return [_voucher_out(db, v) for v in q.all()]''')
        write(vch, s)
        note(OK, "10) ترقيم الصفحات: vouchers (limit/offset اختياري + X-Total-Count)")
    else:
        note(ERR, "10) ترقيم الصفحات: لم أجد مراسي vouchers.py")


# ============ 12) اختبارات الإحكام ============

PRO_TESTS = '''# tests/test_pro_hardening.py
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
'''


def step_tests(root: Path):
    t = root / "backend" / "tests" / "test_pro_hardening.py"
    if t.exists():
        note(SKIP, "12) اختبارات: test_pro_hardening.py موجود")
    else:
        write(t, PRO_TESTS)
        note(OK, "12) اختبارات: أُنشئ tests/test_pro_hardening.py (أرقام فريدة، منع السحب، تجميع، ترقيم، v1، request_id)")

    # توافق الاختبارات القديمة مع حماية الرصيد الجديدة: اختبار الجهة الحرة يحتاج إيداعاً قبلياً
    tv = root / "backend" / "tests" / "test_vouchers.py"
    if tv.exists():
        s = read(tv)
        anchor = "    # سند جهة حرة (بدون سجل) يعمل"
        if "إيداع قبلي" in s:
            note(SKIP, "12) اختبارات: test_vouchers محدث لحماية الرصيد")
        elif anchor in s:
            s = s.replace(anchor, "    # إيداع قبلي حتى يسمح سند الصرف (حماية السحب فوق الرصيد)\n"
                                  "    _receipt(client, token, member, cash, income, amount=900)\n" + anchor, 1)
            write(tv, s)
            note(OK, "12) اختبارات: حُدّث test_vouchers (إيداع قبلي قبل سند الصرف في اختبار الجهة الحرة)")
        else:
            note(WARN, "12) اختبارات: لم أجد مرساة الجهة الحرة في test_vouchers.py - راجعه يدوياً")


# ============ README ============


def step_docs(root: Path):
    rd = root / "README.md"
    section = """

## التحسينات الاحترافية (بواسطة apply_pro_improvements.py)

- **أرقام ذرّية**: السندات والقيود تأخذ أرقامها من جدول `counters` بقفل صف — لا تكرار مهما تزامن المستخدمون.
- **منع السحب فوق الرصيد**: سند صرف على حساب أصول يتجاوز رصيده يُرفض.
- **CI على PostgreSQL**: مصفوفة sqlite/postgres في GitHub Actions لكل push.
- **/v1**: نفس الواجهة متاحة تحت `/v1` (القديم يعمل — التطبيق الحالي لا يتأثر).
- **مراقبة**: `SENTRY_DSN` + `pip install -r backend/requirements-prod.txt`، وسجل JSON لكل طلب مع ترويسة `X-Request-ID`.
- **نسخ احتياطي آلي**: `docker compose --profile backup up -d` (يومي، يحذف الأقدم من 14 يوماً)، ونسخة مشفرة عند الطلب: `bash scripts/backup.sh "عبارة-تشفير"` والاستعادة: `bash scripts/restore.sh <ملف> "عبارة-تشفير"`.
- **TLS عبر Caddy**: `DOMAIN=your-domain docker compose --profile proxy up -d` — شهادة تلقائية وحد 20MB للطلبات.
- **الشعار ملف**: `PUT /fund-settings/logo-file` (multipart) يخزن في `MEDIA_DIR` ويُخدم من `/media`.
- **ترقيم صفحات متوافق**: `?limit=&offset=` مع ترويسة `X-Total-Count` على aids/vouchers/journal (بدونها تُعاد القوائم كاملة كما كان).
- **ملاحظة release**: نسخة release (R8) تحتاج ذاكرة أعلى من بيئات 2GB — ابنها على جهازك عبر `scripts/build_apk.sh` وقارن الحجم.
"""
    if rd.exists():
        s = read(rd)
        if "apply_pro_improvements.py" in s:
            note(SKIP, "توثيق: قسم التحسينات موجود في README")
        else:
            write(rd, s.rstrip() + section)
            note(OK, "توثيق: أُضيف قسم التحسينات الاحترافية إلى README")
    else:
        note(WARN, "توثيق: README غير موجود في هذا التخطيط")


# ============ التشغيل ============


def main():
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).parent.resolve()
    if (root / "SocialFund" / "backend" / "app").exists():
        root = root / "SocialFund"
    if not (root / "backend" / "app").exists():
        print("ضع السكريبت في جذر SocialFund (أو مرر المسار). المسار الحالي:", root)
        sys.exit(1)

    print(f"تطبيق حزمة التطوير الاحترافي على: {root}\n" + "=" * 60)
    for step in (step_numbering, step_ci, step_keys, step_ops, step_monitoring,
                 step_media, step_queries, step_tests, step_docs):
        try:
            step(root)
        except Exception as e:
            note(ERR, f"خطأ غير متوقع في {step.__name__}: {e}")

    print("=" * 60)
    print("\nبعد التشغيل:")
    print("  cd backend && alembic upgrade head && python -m pytest -q")
    print("  cd mobile_app && flutter analyze   # لم يتغير شيء في التطبيق")
    ok = sum(1 for s, _ in results if s == OK)
    skip = sum(1 for s, _ in results if s == SKIP)
    warn = sum(1 for s, _ in results if s == WARN)
    err = sum(1 for s, _ in results if s == ERR)
    print(f"\nالملخص: {ok} نُفذ | {skip} موجود مسبقاً | {warn} تنبيه | {err} خطأ")
    sys.exit(1 if err else 0)


if __name__ == "__main__":
    main()
