from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

from app.schemas.warehouse import WarehouseRead

class PurchaseRequestCreate(SQLModel):
    request_no: str
    request_type: str
    warehouse_id: int
    requested_by: str
    approved_by: Optional[str] = None
    status: str
    reason: str
    request_date: datetime
    approved_date: Optional[datetime] = None

class PurchaseRequestUpdate(SQLModel):
    request_no: Optional[str] = None
    request_type: Optional[str] = None
    warehouse_id: Optional[int] = None
    requested_by: Optional[str] = None
    approved_by: Optional[str] = None
    status: Optional[str] = None
    reason: Optional[str] = None
    request_date: Optional[datetime] = None
    approved_date: Optional[datetime] = None

class PurchaseRequestRead(SQLModel):
    request_no: str
    request_type: str
    warehouse_id: WarehouseRead
    requested_by: str
    approved_by: Optional[str] = None
    status: str
    reason: str
    request_date: datetime
    approved_date: Optional[datetime] = None