from datetime import datetime
from sqlmodel import Field, SQLModel
from typing import Optional

from app.schemas.warehouse.warehouse_base import WarehouseSimple
from app.schemas.product_transfer.product_transfer_item import (
    ProductTransferItemInput,
    ProductTransferItemRead,
)

class ProductTransferCreate(SQLModel):
    from_warehouse_id: int
    to_warehouse_id: int
    reference_no: Optional[str] = None
    transfer_date: datetime = Field(default_factory=datetime.utcnow)
    product_transfer_items: list[ProductTransferItemInput] = Field(min_length=1)

class ProductTransferUpdate(SQLModel):
    from_warehouse_id: Optional[int] = None
    to_warehouse_id: Optional[int] = None
    reference_no: Optional[str] = None
    transfer_date: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    product_transfer_items: Optional[list[ProductTransferItemInput]] = None

class ProductTransferRead(SQLModel):
    id: Optional[int] = None
    from_warehouse: WarehouseSimple
    to_warehouse: WarehouseSimple
    product_transfer_items: list[ProductTransferItemRead] = Field(default_factory=list)
    reference_no: str
    transfer_date: datetime
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class ProductTransferSimple(SQLModel):
    id: Optional[int] = None
    reference_no: str