from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.product_transfer import ProductTransferSimple
from app.schemas.product import ProductSimple

class ProductTransferItemCreate(SQLModel):
    product_transfer_id: int
    product_id: int
    qty: int

class ProductTransferItemUpdate(SQLModel):
    product_transfer_id: Optional[int] = None
    product_id: Optional[int] = None
    qty: Optional[int] = None

class ProductTransferItemRead(SQLModel):
    id: Optional[int] = None
    product_transfer: ProductTransferSimple
    product: ProductSimple
    qty: int