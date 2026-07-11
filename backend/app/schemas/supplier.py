from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator


class SupplierCreate(SQLModel):
    name: str
    phone: str
    email: str
    photo: Optional[str] = None
    map: Optional[str] = None
    address: Optional[str] = None
    status: bool

    @field_validator("name", "phone", "email")
    @classmethod
    def validate_required_fields(cls, v):
        if not v or not str(v).strip():
            raise ValueError("Field cannot be empty")
        return v.strip()


class SupplierUpdate(SQLModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    photo: Optional[str] = None
    map: Optional[str] = None
    address: Optional[str] = None
    status: Optional[bool] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None


class SupplierRead(SQLModel):
    id: Optional[int] = None
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    photo: Optional[str] = None
    map: Optional[str] = None
    address: Optional[str] = None
    status: Optional[bool] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class SupplierSimple(SQLModel):
    id: int
    name: str