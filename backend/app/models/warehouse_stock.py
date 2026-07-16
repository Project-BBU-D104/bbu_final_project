from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List,TYPE_CHECKING
from datetime import datetime

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
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    product: Optional["Product"] = Relationship(back_populates="warehouse_stock")
    warehouse: Optional["Warehouse"] = Relationship(back_populates="warehouse_stock")
    