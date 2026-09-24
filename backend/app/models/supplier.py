from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List
from datetime import datetime, timezone


class Supplier(SQLModel, table=True):
    __tablename__ = "supplier"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    phone: str
    photo: Optional[str] = None
    email: str
    map: str
    address: str
    status: bool
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    purchases: List["Purchase"] = Relationship(back_populates="supplier")
    purchase_payments: List["PurchasePayment"] = Relationship(back_populates="supplier")