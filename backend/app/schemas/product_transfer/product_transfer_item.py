from datetime import datetime
from sqlmodel import Field, SQLModel
from typing import Optional

from app.schemas.product.product import ProductSimple

class ProductTransferItemInput(SQLModel):
    product_id: int
    qty: int = Field(gt=0)

class ProductTransferItemCreate(SQLModel):
    product_transfer_id: int
    product_id: int
    qty: int = Field(gt=0)

class ProductTransferItemUpdate(SQLModel):
    product_transfer_id: Optional[int] = None
    product_id: Optional[int] = None
    qty: Optional[int] = Field(default=None, gt=0)

class ProductTransferItemRead(SQLModel):
    id: Optional[int] = None
    product_transfer_id: int
    product: ProductSimple
    qty: int