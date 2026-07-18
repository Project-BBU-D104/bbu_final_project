from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.user import UserRead
from app.schemas.product import ProductRead
from app.schemas.warehouse import WarehouseRead

class StockAdjustmentCreate(SQLModel):
    user_id: int
    product_id: int
    warehouse_id: int
    adjustment_type: str
    qty: int
    reason: str
    reference_no: str


class StockAdjustmentUpdate(SQLModel):
    user_id: Optional[int] = None
    product_id: Optional[int] = None
    warehouse_id: Optional[int] = None
    adjustment_type: Optional[str] = None
    qty: Optional[int] = None
    previous_qty: Optional[int] = None
    new_qty: Optional[int] = None
    reason: Optional[str] = None
    reference_no: Optional[str] = None
    updated_at: Optional[datetime] = None


class StockAdjustmentRead(SQLModel):
    id: Optional[int] = None
    user: Optional[UserRead] = None
    product: Optional[ProductRead] = None
    warehouse: Optional[WarehouseRead] = None
    adjustment_type: str
    qty: int
    previous_qty: int
    new_qty: int
    reason: str
    reference_no: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
