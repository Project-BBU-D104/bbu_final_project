from decimal import Decimal
from sqlmodel import Field, SQLModel
from typing import Optional
from app.schemas.product.product import ProductSimple

class SaleItemCreate(SQLModel):
    product_id: int
    qty: int = Field(gt=0)

class SaleItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: int
    sale_price: Decimal
    subtotal: Decimal