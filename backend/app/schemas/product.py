from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.category import CategorySimple
from app.schemas.supplier import SupplierSimple

class ProductCreate(SQLModel):
    category_id: int
    supplier_id: int
    name: str
    barcode: str
    photo: str
    cost_price: int
    sale_price: int
    qty: int
    allow_insert_qty: bool
    unit: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None


class ProductUpdate(SQLModel):
    category_id: Optional[int] = None
    supplier_id: Optional[int] = None
    name: Optional[str] = None
    barcode: Optional[str] = None
    photo: Optional[str] = None
    cost_price: Optional[int] = None
    sale_price: Optional[int] = None
    qty: Optional[int] = None
    allow_insert_qty: Optional[bool] = None
    unit: Optional[str] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None


class ProductRead(SQLModel):
    category: CategorySimple
    supplier: SupplierSimple
    name: str
    barcode: str
    photo: Optional[str] = None
    cost_price: Optional[int] = None
    sale_price: Optional[int] = None
    qty: Optional[int] = None
    allow_insert_qty: Optional[bool] = None
    unit: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None


class ProductSimple(SQLModel):
    id: int
    name: str