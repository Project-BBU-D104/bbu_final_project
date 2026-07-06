from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List, TYPE_CHECKING
from datetime import datetime
from app.models.category import Category
from app.models.supplier import Supplier

if TYPE_CHECKING:
    from app.models.purchase_item import PurchaseItem


class Product(SQLModel, table=True):
    __tablename__ = "product"

    id: Optional[int] = Field(default=None, primary_key=True)
    category_id: int = Field(foreign_key="categories.id")
    supplier_id: int = Field(foreign_key="supplier.id")
    name: str
    barcode: str
    photo: str
    cost_price: int
    sale_price: int
    qty: int
    allow_insert_qty: bool
    unit: str
    description: Optional[str] = None
    deleted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    category: Optional["Category"] = Relationship(back_populates="products")
    supplier: Optional["Supplier"] = Relationship(back_populates="products")
    product_transfers: List["ProductTransfer"] = Relationship(back_populates="product")
    stock_adjustments: List["StockAdjustment"] = Relationship(back_populates="product")
    warehouse_stock: List["WarehouseStock"] = Relationship(back_populates="product")
    purchase_items: List["PurchaseItem"] = Relationship(back_populates="product")