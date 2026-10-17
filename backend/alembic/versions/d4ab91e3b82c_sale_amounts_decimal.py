"""store sale amounts as decimals

Revision ID: d4ab91e3b82c
Revises: a13c9d5e27b1, efa0fcb67158
Create Date: 2026-10-17

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


revision: str = "d4ab91e3b82c"
down_revision: Union[str, Sequence[str], None] = ("a13c9d5e27b1", "efa0fcb67158")
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "sales",
        "deleted_at",
        existing_type=sa.DateTime(),
        nullable=True,
    )

    for column in ("subtotal", "tax_amount", "discount_amount", "total_amount", "paid_amount", "due_amount"):
        op.alter_column(
            "sales",
            column,
            existing_type=mysql.INTEGER(),
            type_=sa.Numeric(precision=12, scale=2),
            existing_nullable=False,
        )

    for column in ("sale_price", "subtotal"):
        op.alter_column(
            "sale_items",
            column,
            existing_type=mysql.INTEGER(),
            type_=sa.Numeric(precision=12, scale=2),
            existing_nullable=False,
        )


def downgrade() -> None:
    for column in ("sale_price", "subtotal"):
        op.alter_column(
            "sale_items",
            column,
            existing_type=sa.Numeric(precision=12, scale=2),
            type_=mysql.INTEGER(),
            existing_nullable=False,
        )

    for column in ("due_amount", "paid_amount", "total_amount", "discount_amount", "tax_amount", "subtotal"):
        op.alter_column(
            "sales",
            column,
            existing_type=sa.Numeric(precision=12, scale=2),
            type_=mysql.INTEGER(),
            existing_nullable=False,
        )

    op.alter_column(
        "sales",
        "deleted_at",
        existing_type=sa.DateTime(),
        nullable=False,
    )