from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime


class Warehouse(SQLModel, table=True):
    __tablename__ = "warehouses"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    reference_no: str
    location: str
    note: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    stock_adjustments: List["StockAdjustment"] = Relationship(
        back_populates="warehouse"
    )
    outgoing_transfers: List["ProductTransfer"] = Relationship(
    back_populates="from_warehouse",
    sa_relationship_kwargs={
        "foreign_keys": "ProductTransfer.from_warehouse_id"
    },
)

    incoming_transfers: List["ProductTransfer"] = Relationship(
        back_populates="to_warehouse",
        sa_relationship_kwargs={
            "foreign_keys": "ProductTransfer.to_warehouse_id"
        },
    )

    warehouse_stock: List["WarehouseStock"] = Relationship(back_populates="warehouse")

    purchases: List["Purchase"] = Relationship(back_populates="warehouse")