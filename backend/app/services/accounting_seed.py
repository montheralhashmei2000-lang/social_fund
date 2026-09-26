# app/services/accounting_seed.py
"""شجرة الحسابات الافتراضية — تُنشأ مرة واحدة بشكل آمن (idempotent)."""
from sqlalchemy.orm import Session

from app.models.accounting import Account

DEFAULT_ACCOUNTS = [
    ("1010", "الصندوق النقدي", "asset", dict(is_cash=True)),
    ("1020", "الحساب البنكي الرئيسي", "asset", dict(is_bank=True)),
    ("1030", "محفظة إلكترونية", "asset", dict(is_wallet=True)),
    ("2010", "مستحقات وودائع", "liability", {}),
    ("3010", "حقوق الصندوق (رأس المال)", "equity", {}),
    ("4010", "اشتراكات الأعضاء", "income", {}),
    ("4020", "تبرعات عامة", "income", {}),
    ("4030", "تبرعات حملات", "income", {}),
    ("4040", "غرامات وأخرى", "income", {}),
    ("5010", "مساعدات نقدية", "expense", {}),
    ("5020", "مساعدات عينية", "expense", {}),
    ("5030", "مصروفات إدارية", "expense", {}),
    ("5040", "صيانة وتشغيل", "expense", {}),
]


def ensure_default_accounts(db: Session):
    if db.query(Account).count() > 0:
        return False
    for code, name, atype, extra in DEFAULT_ACCOUNTS:
        db.add(Account(code=code, name=name, type=atype, **extra))
    db.commit()
    return True
