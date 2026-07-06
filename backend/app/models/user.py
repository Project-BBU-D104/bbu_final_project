from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    email: str
    password: str

    audit_logs: List["AuditLogs"] = Relationship(back_populates="user")
    stock_adjustments: List["StockAdjustment"] = Relationship(back_populates="user")