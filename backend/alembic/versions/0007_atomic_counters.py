"""atomic counters for vouchers/journal numbering

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
