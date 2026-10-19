"""add index on user.name

Speeds up the login lookup, which filters on user.name.

Revision ID: a7c1f4e9b2d3
Revises: f1b3c6d8a920
Create Date: 2026-10-19 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a7c1f4e9b2d3'
down_revision: Union[str, Sequence[str], None] = 'f1b3c6d8a920'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_index("ix_user_name", "user", ["name"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index("ix_user_name", table_name="user")
