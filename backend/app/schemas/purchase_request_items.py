from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

from app.schemas.purchase_requests import PurchaseRequestRead
from app.schemas.product import ProductRead

class PurchaseRequestItemCreate(SQLModel):
    stock_request_id: int
    product_id: int
    unit: str
    qty: int

class PurchaseRequestItemUpdate(SQLModel):
    stock_request_id: Optional[int] = None
    product_id: Optional[int] = None
    unit: Optional[str] = None
    qty: Optional[int] = None

class PurchaseRequestItemRead(SQLModel):
    stock_request_id: PurchaseRequestRead
    product_id: ProductRead
    unit: str
    qty: int
    created_at: Optional[datetime] = None
