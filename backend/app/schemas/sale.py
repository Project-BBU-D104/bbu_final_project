from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from app.schemas.user import UserRead
from app.schemas.customer import CustomerSimple
from app.schemas.sale_item import SaleItemRead
from typing import List

class SaleCreate(SQLModel):
    user_id: int
    customer_id: int
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
    created_at: datetime
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None

class SaleUpdate(SQLModel):
    user_id: Optional[int] = None
    customer_id: Optional[int] = None
    invoice_no: Optional[str] = None
    sale_date: Optional[datetime] = None
    subtotal: Optional[int] = None
    tax_amount: Optional[int] = None
    discount_amount: Optional[int] = None
    total_amount: Optional[int] = None
    paid_amount: Optional[int] = None
    due_amount: Optional[int] = None
    payment_status: Optional[str] = None
    status: Optional[str] = None
    payment_method: Optional[str] = None
    updated_at: Optional[datetime] = None

class SaleRead(SQLModel):
    id: Optional[int] = None
    user: UserRead
    customer: CustomerSimple
    sale_items: List[SaleItemRead] = []
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
    payment_method: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None