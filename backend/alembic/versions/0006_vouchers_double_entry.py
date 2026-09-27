"""vouchers linked to double-entry + journal voucher link

Revision ID: 0006_vouchers_double_entry
Revises: 0005_expansion_accounting_welfare
Create Date: 2026-09-26

السندات تصبح جزءاً من القيد المزدوج:
- vouchers: member_id/member_name تصبح اختيارية (الطرف قد يكون مانحاً/مستفيداً/جهة حرة)
  + donor_id, beneficiary_id, party_name + حسابات القيد (treasury/counter) + journal_entry_id.
- journal_entries: + voucher_id لربط القيود بسنداتها.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0006_vouchers_double_entry"
down_revision = "0005_expansion_accounting"
branch_labels = None
depends_on = None

GUID = postgresql.UUID(as_uuid=True)


def upgrade():
    with op.batch_alter_table("vouchers") as b:
        b.alter_column("member_id", existing_type=GUID, nullable=True)
        b.alter_column("member_name", existing_type=sa.String(), nullable=True)
        b.add_column(sa.Column("donor_id", GUID, nullable=True))
        b.add_column(sa.Column("beneficiary_id", GUID, nullable=True))
        b.add_column(sa.Column("party_name", sa.String(255), nullable=True))
        b.add_column(sa.Column("treasury_account_id", GUID, nullable=True))
        b.add_column(sa.Column("counter_account_id", GUID, nullable=True))
        b.add_column(sa.Column("journal_entry_id", GUID, nullable=True))
        b.create_index("ix_vouchers_donor_id", ["donor_id"])
        b.create_index("ix_vouchers_beneficiary_id", ["beneficiary_id"])
        b.create_index("ix_vouchers_treasury_account_id", ["treasury_account_id"])
        b.create_index("ix_vouchers_counter_account_id", ["counter_account_id"])
        b.create_index("ix_vouchers_journal_entry_id", ["journal_entry_id"])

    with op.batch_alter_table("journal_entries") as b:
        b.add_column(sa.Column("voucher_id", GUID, nullable=True))
        b.create_index("ix_journal_entries_voucher_id", ["voucher_id"])


def downgrade():
    with op.batch_alter_table("journal_entries") as b:
        b.drop_index("ix_journal_entries_voucher_id")
        b.drop_column("voucher_id")

    with op.batch_alter_table("vouchers") as b:
        b.drop_index("ix_vouchers_journal_entry_id")
        b.drop_index("ix_vouchers_counter_account_id")
        b.drop_index("ix_vouchers_treasury_account_id")
        b.drop_index("ix_vouchers_beneficiary_id")
        b.drop_index("ix_vouchers_donor_id")
        b.drop_column("journal_entry_id")
        b.drop_column("counter_account_id")
        b.drop_column("treasury_account_id")
        b.drop_column("party_name")
        b.drop_column("beneficiary_id")
        b.drop_column("donor_id")
        b.alter_column("member_name", existing_type=sa.String(), nullable=False)
        b.alter_column("member_id", existing_type=GUID, nullable=False)
