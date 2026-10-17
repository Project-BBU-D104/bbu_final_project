"""store sale payment amounts as decimals

Revision ID: f1b3c6d8a920
Revises: d4ab91e3b82c
Create Date: 2026-10-17

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


revision: str = "f1b3c6d8a920"
down_revision: Union[str, Sequence[str], None] = "d4ab91e3b82c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "sale_payments",
        "amount",
        existing_type=mysql.INTEGER(),
        type_=sa.Numeric(precision=12, scale=2),
        existing_nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "sale_payments",
        "amount",
        existing_type=sa.Numeric(precision=12, scale=2),
        type_=mysql.INTEGER(),
        existing_nullable=False,
    )