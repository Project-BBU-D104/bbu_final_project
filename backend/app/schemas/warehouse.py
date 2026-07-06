from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional


class WarehouseCreate(SQLModel):
    name: str
    location: str
    created_at: datetime
    updated_at: Optional[datetime] = None


class WarehouseUpdate(SQLModel):
    name: Optional[str] = None
    location: Optional[str] = None
    updated_at: Optional[datetime] = None


class WarehouseRead(SQLModel):
    id: Optional[int] = None
    name: str
    location: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
