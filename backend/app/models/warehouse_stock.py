from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,TYPE_CHECKING
from datetime import datetime, timezone

if TYPE_CHECKING:
    from app.models.audit_logs import AuditLogs
    from app.models.product import Product
    from app.models.warehouse import Warehouse

class WarehouseStock(SQLModel, table=True):
    __tablename__ = "warehouse_stock"

    id: Optional[int] = Field(default=None, primary_key=True)
    product_id: int = Field(foreign_key="product.id")      # ✅ REQUIRED
    warehouse_id: int = Field(foreign_key="warehouses.id")  # ✅ REQUIRED
    qty: int
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    product: Optional["Product"] = Relationship(back_populates="warehouse_stock")
    warehouse: Optional["Warehouse"] = Relationship(back_populates="warehouse_stock")
    