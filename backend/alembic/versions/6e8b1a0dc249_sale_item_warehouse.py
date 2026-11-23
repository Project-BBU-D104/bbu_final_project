"""Record the warehouse supplying each sale line."""

from alembic import op
import sqlalchemy as sa

revision = "6e8b1a0dc249"
down_revision = "b8d2e4f6a1c3"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("sale_items", sa.Column("warehouse_id", sa.Integer(), nullable=True))
    op.create_foreign_key("fk_sale_items_warehouse", "sale_items", "warehouses",
                          ["warehouse_id"], ["id"])


def downgrade():
    op.drop_constraint("fk_sale_items_warehouse", "sale_items", type_="foreignkey")
    op.drop_column("sale_items", "warehouse_id")
