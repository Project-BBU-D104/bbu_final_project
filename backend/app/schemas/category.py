from datetime import date
from sqlmodel import SQLModel
from typing import Optional


class CategoryCreate(SQLModel):
    name: str
    description: str
    created_at: date


class CategoryRead(SQLModel):
    id: Optional[int] = None
    name: str
    description: str
    created_at: date
