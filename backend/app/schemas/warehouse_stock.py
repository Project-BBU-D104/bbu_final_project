from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product import ProductRead

from app.schemas.warehouse_base import WarehouseSimple
class WarehouseStockItem(SQLModel):
    product_id: int
    qty: int

class WarehouseStockCreate(SQLModel):
    warehouse_id: int
    items: list[WarehouseStockItem] 

class WarehouseStockUpdate(SQLModel):
    warehouse_id: Optional[int] = None
    items: list[WarehouseStockItem] 

class WarehouseStockRead(SQLModel):
    id: Optional[int] = None
    warehouse_id: int
    warehouse: WarehouseSimple
    product: ProductRead
    qty: int
    note: Optional[str] = None