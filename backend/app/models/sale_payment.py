from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime
from app.models.user import User
from app.models.sale import Sale

# if TYPE_CHECKING:
#     from app.models.purchase_item import PurchaseItem

class SalePayment(SQLModel, table=True):
    __tablename__ = "sale_payments"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    sale_id: int = Field(foreign_key="sales.id")
    amount: int
    payment_method: str
    reference_no: str
    payment_date: datetime = Field(default_factory=datetime.utcnow)
    note: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    user: Optional[User] = Relationship(back_populates="sale_payments")
    sales: Optional[Sale] = Relationship(back_populates="sale_payments")