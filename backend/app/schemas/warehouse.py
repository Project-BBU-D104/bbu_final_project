from datetime import datetime
from sqlmodel import SQLModel
from typing import List, Optional
from pydantic import field_validator

from app.schemas.warehouse_stock import WarehouseStockRead

class WarehouseCreate(SQLModel):
    name: str
    reference_no: str
    location: str
    note: str

    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Warehouse Name cannot be empty")
        return v

class WarehouseUpdate(SQLModel):
    name: Optional[str] = None
    location: Optional[str] = None
    reference_no: Optional[str] = None
    note: Optional[str] = None
    updated_at: Optional[datetime] = None

class WarehouseRead(SQLModel):
    id: Optional[int] = None
    name: str
    warehouse_stock: List[WarehouseStockRead] = []
    reference_no: str
    location: Optional[str] = None
    note: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class WarehouseSimple(SQLModel):
    id: Optional[int] = None
    name: str