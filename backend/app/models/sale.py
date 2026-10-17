from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime, timezone
from decimal import Decimal
from sqlalchemy import Numeric
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
    subtotal: Decimal = Field(sa_type=Numeric(12, 2))
    tax_amount: Decimal = Field(sa_type=Numeric(12, 2))
    discount_amount: Decimal = Field(sa_type=Numeric(12, 2))
    total_amount: Decimal = Field(sa_type=Numeric(12, 2))
    paid_amount: Decimal = Field(sa_type=Numeric(12, 2))
    due_amount: Decimal = Field(sa_type=Numeric(12, 2))
    payment_status: str
    status: str
    payment_method: str
    deleted_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    user: Optional[User] = Relationship(back_populates="sales")
    customer: Optional[Customer] = Relationship(back_populates="sales")
    sale_items: List["SaleItems"] = Relationship(back_populates="sales")
    sale_payments: List["SalePayment"] = Relationship(back_populates="sale")