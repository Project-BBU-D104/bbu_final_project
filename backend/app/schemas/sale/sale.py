from datetime import datetime
from decimal import Decimal
from sqlmodel import Field, SQLModel
from typing import Optional
from app.schemas.user.user import UserRead
from app.schemas.customer.customer import CustomerSimple
from app.schemas.sale.sale_item import SaleItemCreate, SaleItemRead
from typing import List

class SaleCreate(SQLModel):
    user_id: int
    customer_id: int
    invoice_no: str
    sale_date: datetime
    subtotal: Decimal = Field(default=Decimal("0.00"), ge=0)
    tax_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    discount_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    total_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    paid_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    due_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    payment_status: str = "unpaid"
    status: str
    payment_method: str
    sale_items: List[SaleItemCreate] = Field(min_length=1)
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None

class SaleUpdate(SQLModel):
    user_id: Optional[int] = None
    customer_id: Optional[int] = None
    invoice_no: Optional[str] = None
    sale_date: Optional[datetime] = None
    subtotal: Optional[Decimal] = None
    tax_amount: Optional[Decimal] = None
    discount_amount: Optional[Decimal] = None
    total_amount: Optional[Decimal] = None
    paid_amount: Optional[Decimal] = None
    due_amount: Optional[Decimal] = None
    payment_status: Optional[str] = None
    status: Optional[str] = None
    payment_method: Optional[str] = None
    updated_at: Optional[datetime] = None
    sale_items: Optional[List[SaleItemCreate]] = None

class SaleRead(SQLModel):
    id: Optional[int] = None
    user: UserRead
    customer: CustomerSimple
    sale_items: List[SaleItemRead] = Field(default_factory=list)
    invoice_no: str
    sale_date: datetime
    subtotal: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    paid_amount: Decimal
    due_amount: Decimal
    payment_status: str
    status: str
    payment_method: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None