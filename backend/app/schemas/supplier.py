from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional


class SupplierCreate(SQLModel):
    name: str
    phone: str
    email: str
    map: str
    address: str
    status: bool
    created_at: datetime
    updated_at: Optional[datetime] = None


class SupplierUpdate(SQLModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    map: Optional[str] = None
    address: Optional[str] = None
    status: Optional[bool] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None


class SupplierRead(SQLModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    map: Optional[str] = None
    address: Optional[str] = None
    status: Optional[bool] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
