from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product import ProductSimple


class SaleItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: int
    sale_price: int
    subtotal: int