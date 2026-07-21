from sqlmodel import SQLModel, Field,Relationship
from typing import Optional
from datetime import datetime
from app.models.supplier import Supplier
from app.models.purchase import Purchase
from app.models.payment_type import PaymentType
from app.models.currency import Currency

class PurchasePayment(SQLModel, table=True):
    __tablename__ = "purchase_payments"

    id: Optional[int] = Field(default=None, primary_key=True)
    supplier_id: int = Field(foreign_key="supplier.id")
    purchase_id: int = Field(foreign_key="purchases.id")
    payment_type_id: int = Field(foreign_key="payment_type.id")
    currency_id: int = Field(foreign_key="currency.id")
    payment_no: str
    amount: float
    payment_date: datetime
    note: str
    status: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    supplier: Optional[Supplier] = Relationship(back_populates="purchase_payments")
    purchase: Optional[Purchase] = Relationship(back_populates="purchase_payments")
    payment_type: Optional[PaymentType] = Relationship(back_populates="purchase_payments")
    currency: Optional[Currency] = Relationship(back_populates="purchase_payments")