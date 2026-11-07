from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator
from app.schemas.product.product import ProductSimple

from decimal import Decimal

class PurchaseItemCreate(SQLModel):
    product_id: int
    cost_price: Decimal
    qty: Decimal
    subtotal: Decimal

    @field_validator("qty")
    @classmethod
    def whole_units_only(cls, value: Decimal) -> Decimal:
        if value != value.to_integral_value():
            raise ValueError("Quantity must be a whole number.")
        return value

class PurchaseItemRead(SQLModel):
    id: int
    product: ProductSimple
    qty: Decimal
    cost_price: Decimal
    subtotal: Decimal