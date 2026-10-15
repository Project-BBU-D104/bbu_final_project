from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import Field

class PurchaseRequestItemCreate(SQLModel):
    stock_request_id: int = Field(gt=0)
    product_id: int = Field(gt=0)
    unit: str
    qty: int = Field(gt=0)

class PurchaseRequestItemUpdate(SQLModel):
    stock_request_id: Optional[int] = Field(default=None, gt=0)
    product_id: Optional[int] = Field(default=None, gt=0)
    unit: Optional[str] = None
    qty: Optional[int] = Field(default=None, gt=0)

class PurchaseRequestItemRead(SQLModel):
    id: int
    stock_request_id: int
    product_id: int
    unit: str
    qty: int
    created_at: Optional[datetime] = None