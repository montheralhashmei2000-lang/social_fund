# الصندوق الاجتماعي التنموي — النظام المتكامل (حزمة واحدة)

خادم **FastAPI** + تطبيق **Flutter** أندرويد في مشروع واحد، بمعمارية محاسبية كاملة (قيد مزدوج) وتصميم كلاسيكي حديث (أخضر داكن/ذهبي، خط أميري، RTL).

## البنية
```
SocialFund/
├── backend/                  خادم FastAPI (محاسبة، سندات، خيري، RBAC، تشفير حقلي، تدقيق)
│   ├── app/                  الكود (models/routers/services)
│   ├── alembic/              هجرات قاعدة البيانات (0001–0006)
│   └── tests/                46 اختبار pytest
├── mobile_app/               تطبيق Flutter (22 شاشة)
├── docs/SECURITY_REPORT.md   تقرير الأمان والفحوص مع الاختبارات المرافقة
├── scripts/run_backend_dev.sh
├── scripts/build_apk.sh
└── docker-compose.yml
```

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
cd backend && python3 -m pytest -q          # 46 اختبار
cd mobile_app && flutter analyze && flutter test
```
