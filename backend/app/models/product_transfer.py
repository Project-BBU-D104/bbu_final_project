from sqlmodel import SQLModel, Field,Relationship
from typing import TYPE_CHECKING, Optional
from datetime import datetime
from app.models.warehouse import Warehouse

if TYPE_CHECKING:
    from app.models.product_transfer_item import ProductTransferItem

class ProductTransfer(SQLModel, table=True):
    __tablename__ = "product_transfers"

    id: Optional[int] = Field(default=None, primary_key=True)
    from_warehouse_id: int = Field(foreign_key="warehouses.id")
    to_warehouse_id: int = Field(foreign_key="warehouses.id")
    reference_no: str
    transfer_date: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
 
    product_transfer_items: list["ProductTransferItem"] = Relationship(back_populates="product_transfer")
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