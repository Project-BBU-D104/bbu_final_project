from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List, TYPE_CHECKING
from datetime import datetime, timezone

if TYPE_CHECKING:
    from app.models.purchase_payment import PurchasePayment
    from app.models.system_configuration import SystemConfiguration


class PaymentType(SQLModel, table=True):
    __tablename__ = "payment_type"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    status: bool = True
    description: Optional[str] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    purchase_payments: List["PurchasePayment"] = Relationship(back_populates="payment_type")
    system_configuration: Optional["SystemConfiguration"] = Relationship(back_populates="payment_type")