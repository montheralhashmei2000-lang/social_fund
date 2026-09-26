"""members.national_id_search - deterministic search hash for duplicate checks

Revision ID: 0004_member_national_id_search
Revises: 0003_refresh_sessions
Create Date: 2026-09-25 00:00:00

"""
from alembic import op
import sqlalchemy as sa

revision = "0004_member_national_id_search"
down_revision = "0003_refresh_sessions"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("members", sa.Column("national_id_search", sa.String(64), nullable=True))
    op.create_index("ix_members_national_id_search", "members", ["national_id_search"])


def downgrade():
    op.drop_index("ix_members_national_id_search", table_name="members")
    op.drop_column("members", "national_id_search")
