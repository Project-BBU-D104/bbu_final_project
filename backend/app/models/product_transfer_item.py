from sqlmodel import SQLModel, Field,Relationship
from typing import TYPE_CHECKING, Optional
from app.models.product import Product

if TYPE_CHECKING:
    from app.models.product_transfer import ProductTransfer

class ProductTransferItem(SQLModel, table=True):
    __tablename__ = "product_transfer_items"
    id: Optional[int] = Field(default=None, primary_key=True)
    product_id: int = Field(foreign_key="product.id")
    product_transfer_id: int = Field(foreign_key="product_transfers.id")
    qty: int

    product: Optional["Product"] = Relationship(back_populates="product_transfer_items")
    product_transfer: Optional["ProductTransfer"] = Relationship(back_populates="product_transfer_items")