"""Store POS checkout claims and their immutable receipts."""
from alembic import op
import sqlalchemy as sa

revision = "2cb6e932ad07"
down_revision = "6e8b1a0dc249"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "pos_checkouts",
        sa.Column("checkout_id", sa.CHAR(32), primary_key=True),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("request_hash", sa.CHAR(64), nullable=False),
        sa.Column("receipt", sa.JSON(), nullable=True),
    )


def downgrade():
    op.drop_table("pos_checkouts")
