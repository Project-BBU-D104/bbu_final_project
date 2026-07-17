from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product import ProductSimple

class PurchaseItemCreate(SQLModel):
    product_id: int
    cost_price: int
    qty: int
    subtotal: int

class PurchaseItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: int
    cost_price: int
    subtotal: int