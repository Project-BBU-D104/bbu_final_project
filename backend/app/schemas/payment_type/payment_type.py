from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

class PaymentTypeCreate(SQLModel):
    name: str
    description: str
    status: bool

    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be empty")
        return v

class PaymentTypeUpdate(SQLModel):
    name: Optional[str] = None 
    status: Optional[bool] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None

class PaymentTypeRead(SQLModel):
    id: Optional[int] = None
    name: str
    description: Optional[str] = None
    status: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class PaymentTypeSimple(SQLModel):
    id: Optional[int] = None
    name: str