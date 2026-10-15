"""track initial purchase payment separately

Revision ID: a13c9d5e27b1
Revises: 5111827702ce
Create Date: 2026-10-15

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "a13c9d5e27b1"
down_revision: Union[str, Sequence[str], None] = "5111827702ce"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "purchases",
        sa.Column(
            "initial_paid_amount",
            sa.Numeric(10, 2),
            nullable=False,
            server_default=sa.text("0"),
        ),
    )

    op.execute(
        sa.text(
            """
            UPDATE purchases
            SET initial_paid_amount = CASE
                WHEN paid_amount > COALESCE(
                    (
                        SELECT SUM(payment.amount)
                        FROM purchase_payments AS payment
                        WHERE payment.purchase_id = purchases.id
                          AND LOWER(TRIM(payment.status)) = 'completed'
                    ),
                    0
                )
                THEN paid_amount - COALESCE(
                    (
                        SELECT SUM(payment.amount)
                        FROM purchase_payments AS payment
                        WHERE payment.purchase_id = purchases.id
                          AND LOWER(TRIM(payment.status)) = 'completed'
                    ),
                    0
                )
                ELSE 0
            END
            """
        )
    )

    op.alter_column(
        "purchases",
        "initial_paid_amount",
        server_default=None,
        existing_type=sa.Numeric(10, 2),
        existing_nullable=False,
    )


def downgrade() -> None:
    op.drop_column("purchases", "initial_paid_amount")
