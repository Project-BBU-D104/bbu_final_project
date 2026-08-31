from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.purchase_payment import PurchasePayment
    from app.models.product import Product
    from app.models.system_configuration import SystemConfiguration

class Currency(SQLModel, table=True):
    __tablename__ = "currency"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    code: str = Field(unique=True, index=True)
    symbol: str
    exchange_rate: float
    is_default: bool = False
    status: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    purchase_payments: List["PurchasePayment"] = Relationship(back_populates="currency")
    products: List["Product"] = Relationship(back_populates="currency")
    system_configuration: Optional["SystemConfiguration"] = Relationship(back_populates="currency")