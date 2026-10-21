"""add system_configuration_id to user

Links each user to the system configuration whose settings (low stock
warning, defaults) should apply when they are logged in.

Revision ID: b8d2e4f6a1c3
Revises: a7c1f4e9b2d3
Create Date: 2026-10-21 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b8d2e4f6a1c3'
down_revision: Union[str, Sequence[str], None] = 'a7c1f4e9b2d3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column(
        'user',
        sa.Column('system_configuration_id', sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        'fk_user_system_configuration_id',
        'user',
        'system_configuration',
        ['system_configuration_id'],
        ['id'],
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_constraint(
        'fk_user_system_configuration_id',
        'user',
        type_='foreignkey',
    )
    op.drop_column('user', 'system_configuration_id')
