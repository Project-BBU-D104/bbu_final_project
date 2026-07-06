from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime

class Warehouse(SQLModel, table=True):
    __tablename__ = "warehouses"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    location: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    stock_adjustments: List["StockAdjustment"] = Relationship(back_populates="warehouse")