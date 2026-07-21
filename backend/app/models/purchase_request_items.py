from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.warehouse import Warehouse
    from app.models.product import Product
    from app.models.purchase_requests import PurchaseRequest

class PurchaseRequestItems(SQLModel, table=True):
    __tablename__ = "purchase_request_items"

    id: Optional[int] = Field(default=None, primary_key=True)
    purchase_request_id: int = Field(foreign_key="purchase_requests.id")
    product_id: int = Field(foreign_key="product.id")
    unit: str
    qty: int
    created_at: datetime = Field(default_factory=datetime.utcnow)
   
     
    product: Optional["Product"] = Relationship(back_populates="purchase_request_items")
    purchase_request: Optional["PurchaseRequest"] = Relationship(back_populates="purchase_request_items")