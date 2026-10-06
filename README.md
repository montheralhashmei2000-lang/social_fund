# الصندوق الاجتماعي التنموي — النظام المتكامل

تطبيق **Flutter** أندرويد (أونلاين فقط) يعمل مع **أحد خادمين** في هذا المستودع، بمعمارية محاسبية كاملة (قيد مزدوج) وتصميم كلاسيكي حديث (أخضر داكن/ذهبي، خط أميري، RTL).

## الخادمان
| | **Dart** (`SocialFund-Dart-Server/`) — الاتجاه الحالي | **FastAPI** (`backend/`) |
|---|---|---|
| التقنية | Shelf + SQLite (ملف واحد) | Python + PostgreSQL |
| النشر | `deploy/` (Docker + Caddy + Oracle) أو `deploy/run-local.ps1` محلياً | `docker-compose.yml` |
| الدخول | كلمة مرور فقط (OTP معطّل) | كلمة مرور + OTP عبر SMS |
| العملات المتعددة | نعم | لا |
| الاختبارات | `cd SocialFund-Dart-Server && dart test` | `cd backend && python -m pytest -q` (57) |

التطبيق يدعم **عدة خوادم** (مثلاً محلي وسحابي) ويبدّل بينها من شاشة «الخوادم» بلا إعادة بناء؛ `http` مسموح للشبكة المحلية فقط و`https` لما سواها.

## البنية
```
The_fund/
├── SocialFund-Dart-Server/   خادم Dart (الاتجاه الحالي)
├── deploy/                   نشر Dart: deploy.ps1 (سحابي) · run-local.ps1 (محلي) · build-apk.ps1
├── backend/                  خادم FastAPI (محاسبة، سندات، خيري، RBAC، تشفير حقلي، تدقيق)
│   ├── alembic/              هجرات قاعدة البيانات (0001–0007)
│   └── tests/                57 اختبار pytest
├── mobile_app/               تطبيق Flutter
├── docs/SECURITY_REPORT.md   تقرير الأمان والفحوص
└── docker-compose.yml        نشر FastAPI
```

### تشغيل خادم Dart محلياً (شبكة المكتب)
```powershell
.\deployun-local.ps1      # يولّد كلمة مرور المدير ويطبع العناوين لإضافتها في التطبيق
```
البيانات في `local-data\` (قاعدة SQLite + المفاتيح): انسخه كاملاً عند الانتقال إلى الخادم السحابي.

> الأقسام التالية تخص خادم FastAPI.

## التشغيل السريع

### الخادم (تطوير)
```bash
bash scripts/run_backend_dev.sh
```
يجهز بيئة افتراضية، يثبت المتطلبات، يشغّل الهجرات، ثم uvicorn على المنفذ 8000 (توثيق تفاعلي على /docs).

### الخادم (إنتاج عبر Docker)
```bash
cp .env.example .env    # ثم ضع أسراراً حقيقية (الأوامر داخل الملف)
docker compose up -d --build
```
يتطلب Docker مع Compose v2. قاعدة PostgreSQL مع بيانات دائمة على volume.

### بناء التطبيق
```bash
API_BASE_URL=https://your-domain bash scripts/build_apk.sh
# أو يدوياً:
cd mobile_app && flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=... --dart-define=APP_ENV=production
```
ملاحظة: `http://10.0.2.2:8000` يصل للمضيف من محاكي أندرويد؛ للأجهزة الحقيقية استخدم IP الشبكة أو دومين HTTPS.

## المعمارية — كيف ترتبط الأجزاء
- **القيد المزدوج مصدر الحقيقة**: السندات، المساعدات الدورية، التحويلات بين الحسابات، والقيود اليدوية — كلها قيود متوازنة (مدين = دائن) تظهر تلقائياً في شجرة الحسابات، ميزان المراجعة، قائمة الدخل والتدفقات النقدية.
- **السندات (قبض/صرف)**: طرف (عضو/مانح/مستفيد/جهة حرة) + حساب خزينة + حساب مقابل → قيد `JE` متوازن + معاملة خزينة مرآتية (برقم السند) + سند PDF رسمي. الإلغاء بقيد عكسي، والقيد الأصلي يبقى موثقاً.
- **RBAC متزامن**: الخادم يفرض الصلاحيات (`require_permission`) والتطبيق يخفي ما لا يسمح به الدور (admin/accountant/reviewer/viewer).
- **الخصوصية**: بيانات الهويات مشفرة حقلياً مع فهرس بحث مجزأ (SHA-256)، وجلسات OTP + refresh tokens مع تدوير.

## الفحوص
```bash
cd backend && python3 -m pytest -q          # 57 اختبار
cd mobile_app && flutter analyze && flutter test
```

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
