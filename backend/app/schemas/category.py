from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional


class CategoryCreate(SQLModel):
    name: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None


class CategoryUpdate(SQLModel):
    name: Optional[str] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None


class CategoryRead(SQLModel):
    id: Optional[int] = None
    name: str
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
