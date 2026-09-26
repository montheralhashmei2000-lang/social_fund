# seed.py
"""
إنشاء أول حساب مدير - يُشغَّل مرة واحدة بعد إعداد قاعدة البيانات:

    INITIAL_ADMIN_PASSWORD="كلمة_مرور_قوية" python seed.py

التحصين (ملاحظة الفحص 9): لم تعد كلمة المرور ثابتة في الكود. الحساب لا
يُنشأ إلا بكلمة مرور ممررة من متغير بيئة (8 أحرف على الأقل)، ولا تُطبع
كلمة المرور في أي مخرجات.
"""
import os
import sys

from app.core.database import SessionLocal, Base, engine
from app.core.security import hash_password
from app.models.user import User, RoleEnum
from app.models.fund_settings import FundSettings


def main():
    username = os.environ.get("SEED_ADMIN_USERNAME", "admin").strip() or "admin"
    password = os.environ.get("INITIAL_ADMIN_PASSWORD", "").strip()

    if not password:
        print("خطأ: يجب ضبط INITIAL_ADMIN_PASSWORD قبل التشغيل، مثال:")
        print('  INITIAL_ADMIN_PASSWORD="Passw0rd!2025" python seed.py')
        sys.exit(1)
    if len(password) < 8:
        print("خطأ: كلمة المرور الأولية يجب أن تكون 8 أحرف على الأقل.")
        sys.exit(1)
    if os.environ.get("ENV", "").lower() == "production" and os.environ.get("SEED_CONFIRM", "").lower() != "yes":
        print("أنت في بيئة إنتاج. للتأكيد أعد التشغيل مع SEED_CONFIRM=yes")
        sys.exit(1)

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.username == username).first()
        if existing:
            print("حساب المدير موجود مسبقاً - لا تغيير.")
        else:
            admin = User(
                username=username,
                password_hash=hash_password(password),
                full_name="مدير النظام",
                role=RoleEnum.admin,
                avatar_initial="م",
                is_active=True,
            )
            db.add(admin)
            print(f"تم إنشاء حساب المدير: {username}")
            print("مهم: سجّل الدخول وغيّر كلمة المرور فوراً، ثم ألغِ متغير البيئة.")

        if not db.query(FundSettings).first():
            db.add(FundSettings(name="الصندوق الاجتماعي التنموي"))
            print("تم إنشاء صف بيانات الصندوق الافتراضي.")

        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    main()
