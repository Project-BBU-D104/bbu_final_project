from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

class CategoryCreate(SQLModel):
    name: str
    description: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be empty")
        return v

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

class CategorySimple(SQLModel):
    id: int
    name: str