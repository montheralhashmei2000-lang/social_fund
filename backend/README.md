# SocialFundBackend — خادم الصندوق الاجتماعي التنموي (نسخة مُقسّاة)

FastAPI + PostgreSQL + SQLAlchemy + Alembic. **نظام أونلاين فقط** — طبقة المزامنة
(`/sync/*`) أُزيلت نهائيًا مع كل ثغراتها (راجع SECURITY_REPORT.md في جذر المستودع).

## التشغيل

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # ثم املأ القيم الحقيقية

# الإنتاج يتطلب: SECRET_KEY (32+ حرفاً) و FIELD_ENCRYPTION_KEY (Fernet)
# و CORS_ORIGINS بنطاقك الفعلي — وإلا يرفض الخادم الإقلاع.

alembic upgrade head          # قاعدة البيانات (الإنتاج)
INITIAL_ADMIN_PASSWORD="كلمة_مرور_قوية" python seed.py   # أول حساب مدير

uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## بيئة التطوير

```bash
ENV=development uvicorn app.main:app --reload
# تسheets الجداول تلقائياً، ورمز OTP يُطبع في الطرفية في وضع التطوير فقط
# (بديل Twilio). في الإنتاج: فشل SMS يعيد 503 ولا يُطبع أي رمز أبداً.
```

## الاختبارات

```bash
pytest        # 30 اختباراً: مصادقة، صلاحيات، تشفير، rate limiting، إصلاحات أمنية
```

## الإشعارات (اختياري)

ضع ملف بيانات اعتماد Firebase Admin **خارج مجلد المشروع** وأشر إليه عبر
`FIREBASE_CREDENTIALS_PATH` في `.env`. غيابه يعطّل الإشعارات فقط دون إيقاف الخادم.

## الخطوط العربية للتقارير (مطلوبة في الإنتاج)

ضع `Amiri-Regular.ttf` و`Amiri-Bold.ttf` في `app/static/fonts/` (حمّلهما من
fonts.google.com/specimen/Amiri). غيابهما في الإنتاج يفشل بوضوح بدل إنتاج PDF بعربية مكسورة.
