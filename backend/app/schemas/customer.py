from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional


class CustomerCreate(SQLModel):
    name: str
    photo: str
    phone: str
    address: str
    created_at: datetime
    updated_at: Optional[datetime] = None


class CustomerUpdate(SQLModel):
    name: Optional[str] = None
    photo: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    updated_at: Optional[datetime] = None


class CustomerRead(SQLModel):
    id: Optional[int] = None
    name: str
    photo: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
