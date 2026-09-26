"""accounting core + donors/campaigns + welfare expansion

Revision ID: 0005_expansion_accounting_welfare
Revises: 0004_member_national_id_search
Create Date: 2026-09-26 00:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0005_expansion_accounting_welfare"
down_revision = "0004_member_national_id_search"
branch_labels = None
depends_on = None

GUID = postgresql.UUID(as_uuid=True)
MONEY = sa.Numeric(14, 2)


def upgrade():
    op.create_table(
        "accounts",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("code", sa.String(20), nullable=False),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("type", sa.String(20), nullable=False),
        sa.Column("is_bank", sa.Boolean, nullable=True),
        sa.Column("is_cash", sa.Boolean, nullable=True),
        sa.Column("is_wallet", sa.Boolean, nullable=True),
        sa.Column("bank_name", sa.String(120), nullable=True),
        sa.Column("account_number", sa.String(60), nullable=True),
        sa.Column("currency", sa.String(8), nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_accounts_code", "accounts", ["code"], unique=True)
    op.create_index("ix_accounts_type", "accounts", ["type"])

    op.create_table(
        "journal_entries",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("entry_no", sa.String(20), nullable=False),
        sa.Column("entry_date", sa.Date, nullable=False),
        sa.Column("description", sa.String(255), nullable=False),
        sa.Column("entry_type", sa.String(30), nullable=False),
        sa.Column("reference", sa.String(60), nullable=True),
        sa.Column("status", sa.String(12), nullable=True),
        sa.Column("campaign_id", GUID, nullable=True),
        sa.Column("donor_id", GUID, nullable=True),
        sa.Column("member_id", GUID, nullable=True),
        sa.Column("aid_id", GUID, nullable=True),
        sa.Column("beneficiary_id", GUID, nullable=True),
        sa.Column("created_by", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_journal_entries_entry_no", "journal_entries", ["entry_no"], unique=True)
    op.create_index("ix_journal_entries_entry_date", "journal_entries", ["entry_date"])
    op.create_index("ix_journal_entries_entry_type", "journal_entries", ["entry_type"])
    op.create_index("ix_journal_entries_status", "journal_entries", ["status"])

    op.create_table(
        "journal_lines",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("entry_id", GUID, sa.ForeignKey("journal_entries.id"), nullable=False),
        sa.Column("account_id", GUID, sa.ForeignKey("accounts.id"), nullable=False),
        sa.Column("debit", MONEY, nullable=False),
        sa.Column("credit", MONEY, nullable=False),
        sa.Column("memo", sa.String(255), nullable=True),
    )
    op.create_index("ix_journal_lines_entry_id", "journal_lines", ["entry_id"])
    op.create_index("ix_journal_lines_account_id", "journal_lines", ["account_id"])

    op.create_table(
        "bank_statement_lines",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("account_id", GUID, sa.ForeignKey("accounts.id"), nullable=False),
        sa.Column("line_date", sa.Date, nullable=False),
        sa.Column("description", sa.String(255), nullable=False),
        sa.Column("amount", MONEY, nullable=False),
        sa.Column("external_ref", sa.String(60), nullable=True),
        sa.Column("matched_line_id", GUID, sa.ForeignKey("journal_lines.id"), nullable=True),
        sa.Column("created_by", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_bank_statement_lines_account_id", "bank_statement_lines", ["account_id"])

    op.create_table(
        "donors",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("name", sa.String(160), nullable=False),
        sa.Column("donor_type", sa.String(20), nullable=True),
        sa.Column("tier", sa.String(20), nullable=True),
        sa.Column("phone", sa.String(64), nullable=True),
        sa.Column("email", sa.String(255), nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_donors_name", "donors", ["name"])
    op.create_index("ix_donors_tier", "donors", ["tier"])

    op.create_table(
        "pledges",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("donor_id", GUID, sa.ForeignKey("donors.id"), nullable=False),
        sa.Column("amount", MONEY, nullable=False),
        sa.Column("frequency", sa.String(20), nullable=True),
        sa.Column("start_date", sa.Date, nullable=False),
        sa.Column("end_date", sa.Date, nullable=True),
        sa.Column("status", sa.String(12), nullable=True),
        sa.Column("last_fulfilled_on", sa.Date, nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_pledges_donor_id", "pledges", ["donor_id"])
    op.create_index("ix_pledges_status", "pledges", ["status"])

    op.create_table(
        "campaigns",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("name", sa.String(160), nullable=False),
        sa.Column("description", sa.Text, nullable=True),
        sa.Column("goal_amount", MONEY, nullable=False),
        sa.Column("start_date", sa.Date, nullable=False),
        sa.Column("end_date", sa.Date, nullable=True),
        sa.Column("status", sa.String(12), nullable=True),
        sa.Column("created_by", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_campaigns_name", "campaigns", ["name"])
    op.create_index("ix_campaigns_status", "campaigns", ["status"])

    op.create_table(
        "beneficiaries",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("full_name", sa.String(160), nullable=False),
        sa.Column("national_id", sa.String(64), nullable=True),
        sa.Column("national_id_search", sa.String(64), nullable=True),
        sa.Column("phone", sa.String(64), nullable=True),
        sa.Column("family_size", sa.Integer, nullable=True),
        sa.Column("monthly_income", MONEY, nullable=True),
        sa.Column("housing", sa.String(40), nullable=True),
        sa.Column("case_summary", sa.Text, nullable=True),
        sa.Column("status", sa.String(12), nullable=True),
        sa.Column("registered_by", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_beneficiaries_full_name", "beneficiaries", ["full_name"])
    op.create_index("ix_beneficiaries_national_id_search", "beneficiaries", ["national_id_search"])

    op.create_table(
        "periodic_aids",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("beneficiary_id", GUID, sa.ForeignKey("beneficiaries.id"), nullable=False),
        sa.Column("monthly_amount", MONEY, nullable=False),
        sa.Column("started_on", sa.Date, nullable=False),
        sa.Column("status", sa.String(12), nullable=True),
        sa.Column("last_paid_period", sa.String(7), nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_periodic_aids_beneficiary_id", "periodic_aids", ["beneficiary_id"])

    op.create_table(
        "in_kind_items",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("name", sa.String(140), nullable=False),
        sa.Column("unit", sa.String(30), nullable=True),
        sa.Column("quantity", MONEY, nullable=True),
        sa.Column("reorder_level", MONEY, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_in_kind_items_name", "in_kind_items", ["name"])

    op.create_table(
        "in_kind_movements",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("item_id", GUID, sa.ForeignKey("in_kind_items.id"), nullable=False),
        sa.Column("direction", sa.String(6), nullable=False),
        sa.Column("quantity", MONEY, nullable=False),
        sa.Column("movement_date", sa.Date, nullable=False),
        sa.Column("beneficiary_id", GUID, nullable=True),
        sa.Column("aid_id", GUID, nullable=True),
        sa.Column("campaign_id", GUID, nullable=True),
        sa.Column("note", sa.String(255), nullable=True),
        sa.Column("by_user_id", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_in_kind_movements_item_id", "in_kind_movements", ["item_id"])

    op.create_table(
        "budgets",
        sa.Column("id", GUID, primary_key=True),
        sa.Column("period", sa.String(7), nullable=False),
        sa.Column("account_id", GUID, sa.ForeignKey("accounts.id"), nullable=False),
        sa.Column("planned_amount", MONEY, nullable=False),
        sa.Column("created_by", GUID, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.UniqueConstraint("period", "account_id", name="uq_budget_period_account"),
    )
    op.create_index("ix_budgets_period", "budgets", ["period"])

    # أعمدة إضافية على جدول المساعدات: صانع القيد + المستفيد
    op.add_column("aids", sa.Column("created_by", GUID, nullable=True))
    op.add_column("aids", sa.Column("beneficiary_id", GUID, nullable=True))


def downgrade():
    op.drop_column("aids", "beneficiary_id")
    op.drop_column("aids", "created_by")
    for t in ("budgets", "in_kind_movements", "in_kind_items", "periodic_aids", "beneficiaries",
              "campaigns", "pledges", "donors", "bank_statement_lines", "journal_lines",
              "journal_entries", "accounts"):
        op.drop_table(t)
