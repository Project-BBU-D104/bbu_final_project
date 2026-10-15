from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

class PurchaseRequestCreate(SQLModel):
    request_no: Optional[str] = None
    request_type: str
    warehouse_id: int
    requested_by: str
    approved_by: str
    status: str
    reason: str
    request_date: datetime
    approved_date: datetime

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
    id: int
    request_no: str
    request_type: str
    warehouse_id: int
    requested_by: str
    approved_by: str
    status: str
    reason: str
    request_date: datetime
    approved_date: datetime
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None