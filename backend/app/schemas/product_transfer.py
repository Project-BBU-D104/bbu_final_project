from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.warehouse_base import WarehouseSimple
from app.schemas.product import ProductRead


class ProductTransferCreate(SQLModel):
    from_warehouse_id: int
    to_warehouse_id: int
    product_id: int
    reference_no: str
    qty: int
    transfer_date: datetime
    created_at: datetime
    updated_at: Optional[datetime] = None


class ProductTransferUpdate(SQLModel):
    from_warehouse_id: Optional[int] = None
    to_warehouse_id: Optional[int] = None
    product_id: Optional[int] = None
    reference_no: Optional[str] = None
    qty: Optional[int] = None
    transfer_date: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ProductTransferRead(SQLModel):
    id: Optional[int] = None
    from_warehouse: WarehouseSimple
    to_warehouse: WarehouseSimple
    product: ProductRead
    reference_no: str
    qty: int
    transfer_date: datetime
    updated_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
