from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product import ProductSimple


class PurchaseItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: int
    cost_price: int
    subtotal: int