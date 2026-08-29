from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from decimal import Decimal

from app.schemas.category.category import CategorySimple
from app.schemas.unit.unit import UnitSimple
from app.schemas.currency.currency import CurrencySimple

class ProductCreate(SQLModel):
    category_id: int
    unit_id: int
    currency_id: int
    name: str
    barcode: str
    photo: str
    cost_price: Decimal
    sale_price: Decimal
    description: Optional[str] = None

class ProductUpdate(SQLModel):
    category_id: Optional[int] = None
    currency_id: Optional[int] = None
    unit_id: Optional[int] = None
    name: Optional[str] = None
    barcode: Optional[str] = None
    photo: Optional[str] = None
    cost_price: Optional[Decimal] = None
    sale_price: Optional[Decimal] = None
    qty: Optional[int] = None
    allow_insert_qty: Optional[bool] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None

class ProductRead(SQLModel):
    id: int
    category: CategorySimple
    unit: UnitSimple
    currency: CurrencySimple
    name: str
    barcode: str
    photo: Optional[str] = None
    cost_price: Optional[Decimal] = None
    sale_price: Optional[Decimal] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None

class ProductSimple(SQLModel):
    id: int
    name: str