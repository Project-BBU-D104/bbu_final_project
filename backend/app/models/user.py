from datetime import datetime

from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List,TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.audit_logs import AuditLogs
    from app.models.stock_adjustment import StockAdjustment
    from app.models.purchase import Purchase
    from app.models.sale import Sale
    from app.models.sale_payment import SalePayment
    from app.models.role import Role

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    email: str
    password: str
    role_id: int = Field(foreign_key="role.id")
    phone: Optional[str]
    photo: Optional[str]
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    is_active: bool = Field(default=False)

    audit_logs: List["AuditLogs"] = Relationship(back_populates="user")
    stock_adjustments: List["StockAdjustment"] = Relationship(back_populates="user")
    purchases: List["Purchase"] = Relationship(back_populates="user")
    sales: List["Sale"] = Relationship(back_populates="user")
    sale_payments: List["SalePayment"] = Relationship(back_populates="user")
    role: Optional["Role"] = Relationship(back_populates="users")