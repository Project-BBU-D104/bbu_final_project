from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.product import ProductRead

class WarehouseStockRead(SQLModel):
    product: ProductRead
    qty: int
    note: Optional[str] = None