from sqlmodel import SQLModel
from typing import Optional
from app.schemas.product.product import ProductSimple

from decimal import Decimal

class PurchaseItemCreate(SQLModel):
    product_id: int
    cost_price: Decimal
    qty: Decimal
    subtotal: Decimal

class PurchaseItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: Decimal
    cost_price: Decimal
    subtotal: Decimal