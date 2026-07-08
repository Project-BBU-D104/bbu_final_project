from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime
from app.models.product import Product

if TYPE_CHECKING:
    from app.models.sale import Sale

class SaleItems(SQLModel, table=True):
    __tablename__ = "sale_items"

    id: Optional[int] = Field(default=None, primary_key=True)
    sale_id: int = Field(foreign_key="sales.id")
    product_id: int = Field(foreign_key="product.id")
    qty: int
    sale_price: int
    subtotal: int
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    sales: Optional["Sale"] = Relationship(back_populates="sale_items")
    product: Optional[Product] = Relationship(back_populates="sale_items")