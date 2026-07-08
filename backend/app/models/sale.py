from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime
from app.models.user import User
from app.models.customer import Customer

if TYPE_CHECKING:
    from app.models.sale_items import SaleItems
    from app.models.sale_payment import SalePayment

class Sale(SQLModel, table=True):
    __tablename__ = "sales"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    customer_id: int = Field(foreign_key="customers.id")
    invoice_no: str
    sale_date: datetime
    subtotal: int
    tax_amount: int
    discount_amount: int
    total_amount: int
    paid_amount: int
    due_amount: int
    payment_status: str
    status: str
    payment_method: str
    deleted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    user: Optional[User] = Relationship(back_populates="sales")
    customer: Optional[Customer] = Relationship(back_populates="sales")
    sale_items: List["SaleItems"] = Relationship(back_populates="sales")
    sale_payments: List["SalePayment"] = Relationship(back_populates="sales")