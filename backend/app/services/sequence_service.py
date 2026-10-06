# app/services/sequence_service.py
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


def next_entry_no(db) -> str:
    """رقم قيد يومية فريد (JE-000123) من عدّاد ذرّي، مع تخطي أي رقم موجود مسبقاً
    (قيود قديمة رُقّمت بعدّ الصفوف) فلا يقع تعارض مع القيد UNIQUE على entry_no."""
    from app.models.accounting import JournalEntry
    while True:
        no = f"JE-{next_number(db, 'journal_entry'):06d}"
        if not db.query(JournalEntry.id).filter(JournalEntry.entry_no == no).first():
            return no
