from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.purchase_payment import PurchasePayment

class PaymentType(SQLModel, table=True):
    __tablename__ = "payment_type"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    status: bool = True
    description: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    purchase_payments: List["PurchasePayment"] = Relationship(back_populates="payment_type")