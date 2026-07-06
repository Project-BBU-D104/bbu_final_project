from sqlmodel import SQLModel, Field,Relationship
from typing import Optional
from datetime import datetime
from app.models.product import Product
from app.models.warehouse import Warehouse
from app.models.user import User

class StockAdjustment(SQLModel, table=True):
    __tablename__ = "stock_adjustments"

    id: Optional[int] = Field(default=None, primary_key=True)
    product_id: int = Field(foreign_key="product.id")
    warehouse_id: int = Field(foreign_key="warehouses.id")
    user_id: int = Field(foreign_key="user.id")
    adjustment_type: str
    qty: int
    previous_qty: int
    new_qty: int
    reason: str
    reference_no: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    user: Optional["User"] = Relationship(back_populates="stock_adjustments")
    product: Optional["Product"] = Relationship(back_populates="stock_adjustments")
    warehouse: Optional["Warehouse"] = Relationship(back_populates="stock_adjustments")