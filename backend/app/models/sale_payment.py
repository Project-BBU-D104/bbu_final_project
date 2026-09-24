from sqlmodel import SQLModel, Field,Relationship
from typing import Optional
from datetime import datetime, timezone
from app.models.user import User
from app.models.sale import Sale


class SalePayment(SQLModel, table=True):
    __tablename__ = "sale_payments"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    sale_id: int = Field(foreign_key="sales.id")
    amount: int
    payment_method: str
    reference_no: str
    payment_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    note: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    user: Optional[User] = Relationship(back_populates="sale_payments")
    sale: Optional[Sale] = Relationship(back_populates="sale_payments")