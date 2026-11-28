"""Record the currency used for new sale totals.

Revision ID: c72d9b34e610
Revises: b8d2e4f6a1c3
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "c72d9b34e610"
down_revision: Union[str, Sequence[str], None] = "b8d2e4f6a1c3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("sales", sa.Column("currency_code", sa.String(length=16), nullable=True))
    op.add_column("sales", sa.Column("currency_symbol", sa.String(length=16), nullable=True))
    op.add_column("sale_items", sa.Column("original_unit_price", sa.Numeric(12, 2), nullable=True))
    op.add_column("sale_items", sa.Column("original_currency_code", sa.String(length=16), nullable=True))
    op.add_column("sale_items", sa.Column("original_currency_symbol", sa.String(length=16), nullable=True))


def downgrade() -> None:
    op.drop_column("sale_items", "original_currency_symbol")
    op.drop_column("sale_items", "original_currency_code")
    op.drop_column("sale_items", "original_unit_price")
    op.drop_column("sales", "currency_symbol")
    op.drop_column("sales", "currency_code")
