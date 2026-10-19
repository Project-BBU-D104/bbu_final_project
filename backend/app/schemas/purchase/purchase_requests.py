from datetime import datetime, timezone
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

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

    @field_validator("request_date", "approved_date")
    @classmethod
    def ensure_dates_have_timezone(cls, value: datetime) -> datetime:
        if value.tzinfo is None or value.utcoffset() is None:
            return value.replace(tzinfo=timezone.utc)
        return value

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

    @field_validator("request_date", "approved_date")
    @classmethod
    def ensure_dates_have_timezone(
        cls,
        value: Optional[datetime],
    ) -> Optional[datetime]:
        if value is not None and (value.tzinfo is None or value.utcoffset() is None):
            return value.replace(tzinfo=timezone.utc)
        return value

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