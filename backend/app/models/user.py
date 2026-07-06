from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List,TYPE_CHECKING


if TYPE_CHECKING:
    from app.models.audit_logs import AuditLogs
    from app.models.stock_adjustment import StockAdjustment
    from app.models.purchase import Purchase

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    email: str
    password: str

    audit_logs: List["AuditLogs"] = Relationship(back_populates="user")
    stock_adjustments: List["StockAdjustment"] = Relationship(back_populates="user")
    purchases: List["Purchase"] = Relationship(back_populates="user")
