"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2025-01-01 00:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def _sync_columns():
    return [
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("deleted", sa.Boolean(), nullable=True),
        sa.Column("device_id", sa.String(), nullable=True),
    ]


def upgrade():
    # create_type=False: الأنواع تُنشأ يدوياً أدناه (checkfirst=True) - بدونها
    # يحاول SQLAlchemy إنشاءها مرة أخرى تلقائياً عند إنشاء الجدول فيفشل بـ
    # "type already exists" (يظهر فقط على PostgreSQL حقيقي، لا على SQLite).
    role_enum = postgresql.ENUM("admin", "accountant", "reviewer", "viewer", name="roleenum", create_type=False)
    member_status_enum = postgresql.ENUM("نشط", "معلق", name="memberstatus", create_type=False)
    aid_status_enum = postgresql.ENUM("قيد المراجعة", "معتمدة", "مصروفة", "مرفوضة", name="aidstatus", create_type=False)
    treasury_type_enum = postgresql.ENUM("إيراد", "مصروف", name="treasurytype", create_type=False)
    voucher_kind_enum = postgresql.ENUM("قبض", "صرف", name="voucherkind", create_type=False)

    bind = op.get_bind()
    role_enum.create(bind, checkfirst=True)
    member_status_enum.create(bind, checkfirst=True)
    aid_status_enum.create(bind, checkfirst=True)
    treasury_type_enum.create(bind, checkfirst=True)
    voucher_kind_enum.create(bind, checkfirst=True)

    op.create_table(
        "users",
        *_sync_columns(),
        sa.Column("username", sa.String(), nullable=False),
        sa.Column("password_hash", sa.String(), nullable=False),
        sa.Column("full_name", sa.String(), nullable=False),
        sa.Column("role", role_enum, nullable=False),
        sa.Column("avatar_initial", sa.String(length=2), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("phone", sa.String(), nullable=True),
        sa.Column("otp_enabled", sa.Boolean(), nullable=True),
        sa.Column("biometric_enabled", sa.Boolean(), nullable=True),
        sa.UniqueConstraint("username"),
    )
    op.create_index("ix_users_updated_at", "users", ["updated_at"])
    op.create_index("ix_users_deleted", "users", ["deleted"])
    op.create_index("ix_users_username", "users", ["username"])

    op.create_table(
        "members",
        *_sync_columns(),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("national_id", sa.String(length=255), nullable=False),
        sa.Column("phone", sa.String(length=255), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=True),
        sa.Column("city", sa.String(), nullable=True),
        sa.Column("join_date", sa.String(), nullable=True),
        sa.Column("status", member_status_enum, nullable=True),
        sa.Column("monthly_subscription", sa.Integer(), nullable=True),
        sa.Column("total_paid", sa.Integer(), nullable=True),
        sa.Column("balance_due", sa.Integer(), nullable=True),
    )
    op.create_index("ix_members_updated_at", "members", ["updated_at"])
    op.create_index("ix_members_deleted", "members", ["deleted"])
    op.create_index("ix_members_name", "members", ["name"])

    op.create_table(
        "aid_requests",
        *_sync_columns(),
        sa.Column("member_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("members.id"), nullable=False),
        sa.Column("member_name", sa.String(), nullable=False),
        sa.Column("aid_type", sa.String(), nullable=False),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("request_date", sa.String(), nullable=False),
        sa.Column("status", aid_status_enum, nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("reviewer_name", sa.String(), nullable=True),
        sa.Column("reviewer_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
    )
    op.create_index("ix_aid_requests_updated_at", "aid_requests", ["updated_at"])
    op.create_index("ix_aid_requests_deleted", "aid_requests", ["deleted"])
    op.create_index("ix_aid_requests_member_id", "aid_requests", ["member_id"])

    op.create_table(
        "subscriptions",
        *_sync_columns(),
        sa.Column("member_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("members.id"), nullable=False),
        sa.Column("member_name", sa.String(), nullable=False),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("payment_date", sa.String(), nullable=False),
        sa.Column("method", sa.String(), nullable=False),
        sa.Column("reference_no", sa.String(), nullable=True),
    )
    op.create_index("ix_subscriptions_updated_at", "subscriptions", ["updated_at"])
    op.create_index("ix_subscriptions_deleted", "subscriptions", ["deleted"])
    op.create_index("ix_subscriptions_member_id", "subscriptions", ["member_id"])

    op.create_table(
        "treasury_entries",
        *_sync_columns(),
        sa.Column("type", treasury_type_enum, nullable=False),
        sa.Column("category", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("entry_date", sa.String(), nullable=False),
        sa.Column("reference_no", sa.String(), nullable=True),
    )
    op.create_index("ix_treasury_entries_updated_at", "treasury_entries", ["updated_at"])
    op.create_index("ix_treasury_entries_deleted", "treasury_entries", ["deleted"])

    op.create_table(
        "vouchers",
        *_sync_columns(),
        sa.Column("voucher_no", sa.String(), nullable=False),
        sa.Column("kind", voucher_kind_enum, nullable=False),
        sa.Column("member_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("members.id"), nullable=False),
        sa.Column("member_name", sa.String(), nullable=False),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("voucher_date", sa.String(), nullable=False),
        sa.Column("method", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("issued_by_name", sa.String(), nullable=False),
        sa.Column("issued_by_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("status", sa.String(), nullable=True),
        sa.UniqueConstraint("voucher_no"),
    )
    op.create_index("ix_vouchers_updated_at", "vouchers", ["updated_at"])
    op.create_index("ix_vouchers_deleted", "vouchers", ["deleted"])
    op.create_index("ix_vouchers_voucher_no", "vouchers", ["voucher_no"])
    op.create_index("ix_vouchers_member_id", "vouchers", ["member_id"])

    op.create_table(
        "messages",
        *_sync_columns(),
        sa.Column("from_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("from_name", sa.String(), nullable=False),
        sa.Column("to_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("to_name", sa.String(), nullable=False),
        sa.Column("body", sa.Text(), nullable=False),
        sa.Column("read", sa.Boolean(), nullable=True),
    )
    op.create_index("ix_messages_updated_at", "messages", ["updated_at"])
    op.create_index("ix_messages_deleted", "messages", ["deleted"])

    op.create_table(
        "events",
        *_sync_columns(),
        sa.Column("title", sa.String(), nullable=False),
        sa.Column("event_date", sa.String(), nullable=False),
        sa.Column("event_time", sa.String(), nullable=True),
        sa.Column("place", sa.String(), nullable=True),
        sa.Column("type", sa.String(), nullable=True),
        sa.Column("color", sa.String(), nullable=True),
    )
    op.create_index("ix_events_updated_at", "events", ["updated_at"])
    op.create_index("ix_events_deleted", "events", ["deleted"])

    op.create_table(
        "fund_settings",
        *_sync_columns(),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("logo_base64", sa.Text(), nullable=True),
        sa.Column("phone", sa.String(), nullable=True),
        sa.Column("email", sa.String(), nullable=True),
        sa.Column("address", sa.String(), nullable=True),
        sa.Column("registration_no", sa.String(), nullable=True),
    )
    op.create_index("ix_fund_settings_updated_at", "fund_settings", ["updated_at"])
    op.create_index("ix_fund_settings_deleted", "fund_settings", ["deleted"])

    op.create_table(
        "audit_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("timestamp", sa.DateTime(timezone=True), nullable=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("user_name", sa.String(), nullable=True),
        sa.Column("action", sa.String(), nullable=False),
        sa.Column("resource_type", sa.String(), nullable=False),
        sa.Column("resource_id", sa.String(), nullable=True),
        sa.Column("summary", sa.String(), nullable=True),
        sa.Column("changes", sa.Text(), nullable=True),
        sa.Column("ip_address", sa.String(), nullable=True),
        sa.Column("device_id", sa.String(), nullable=True),
    )
    op.create_index("ix_audit_logs_timestamp", "audit_logs", ["timestamp"])


def downgrade():
    op.drop_table("audit_logs")
    op.drop_table("fund_settings")
    op.drop_table("events")
    op.drop_table("messages")
    op.drop_table("vouchers")
    op.drop_table("treasury_entries")
    op.drop_table("subscriptions")
    op.drop_table("aid_requests")
    op.drop_table("members")
    op.drop_table("users")

    bind = op.get_bind()
    postgresql.ENUM(name="voucherkind").drop(bind, checkfirst=True)
    postgresql.ENUM(name="treasurytype").drop(bind, checkfirst=True)
    postgresql.ENUM(name="aidstatus").drop(bind, checkfirst=True)
    postgresql.ENUM(name="memberstatus").drop(bind, checkfirst=True)
    postgresql.ENUM(name="roleenum").drop(bind, checkfirst=True)
