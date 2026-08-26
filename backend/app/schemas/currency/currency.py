from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

class CurrencyCreate(SQLModel):
    name: str
    code: str
    symbol: str
    exchange_rate: float
    is_default: bool
    status: bool

    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be empty")
        return v

class CurrencyUpdate(SQLModel):
    name: Optional[str] = None
    code: Optional[str] = None
    symbol: Optional[str] = None
    exchange_rate: Optional[float] = None
    is_default: Optional[bool] = None
    status: Optional[bool] = None
    updated_at: Optional[datetime] = None

class CurrencyRead(SQLModel):
    id: Optional[int] = None
    name: str
    code: str
    symbol: str
    exchange_rate: float
    is_default: bool
    status: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class CurrencySimple(SQLModel):
    id: Optional[int] = None
    name: str
    symbol: str