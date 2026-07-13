from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product import ProductRead

class WarehouseStockCreate(SQLModel):
    warehouse_id: int
    product_id: int
    qty: int

class WarehouseStockUpdate(SQLModel):
    warehouse_id: Optional[int] = None
    product_id: Optional[int] = None
    qty: Optional[int] = None


class WarehouseStockRead(SQLModel):
    id: Optional[int] = None
    product: ProductRead
    qty: int
    note: Optional[str] = None