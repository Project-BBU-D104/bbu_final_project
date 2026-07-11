from sqlmodel import SQLModel, Field,Relationship
from typing import Optional
from datetime import datetime
from app.models.product import Product
from app.models.warehouse import Warehouse

class ProductTransfer(SQLModel, table=True):
    __tablename__ = "product_transfers"

    id: Optional[int] = Field(default=None, primary_key=True)
    product_id: int = Field(foreign_key="product.id")
    from_warehouse_id: int = Field(foreign_key="warehouses.id")
    to_warehouse_id: int = Field(foreign_key="warehouses.id")
    reference_no: str
    qty: str
    transfer_date: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    product: Optional["Product"] = Relationship(back_populates="product_transfers")
    from_warehouse: Optional["Warehouse"] = Relationship(
        back_populates="outgoing_transfers",
        sa_relationship_kwargs={
            "foreign_keys": "ProductTransfer.from_warehouse_id"
        },
    )
    to_warehouse: Optional["Warehouse"] = Relationship(
        back_populates="incoming_transfers",
        sa_relationship_kwargs={
            "foreign_keys": "ProductTransfer.to_warehouse_id"
        },
    )