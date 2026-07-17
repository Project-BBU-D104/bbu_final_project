from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime
from app.models.product import Product
from app.models.purchase import Purchase


if TYPE_CHECKING:
    from app.models.purchase import Purchase

class PurchaseItem(SQLModel, table=True):
    __tablename__ = "purchase_items"

    id: Optional[int] = Field(default=None, primary_key=True)
    purchase_id: int = Field(foreign_key="purchases.id")
    product_id: int = Field(foreign_key="product.id")
    cost_price: int
    qty: int
    subtotal: int
    deleted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    purchase: Optional["Purchase"] = Relationship(
        back_populates="purchase_items"
    )
    product: Optional["Product"] = Relationship(back_populates="purchase_items")