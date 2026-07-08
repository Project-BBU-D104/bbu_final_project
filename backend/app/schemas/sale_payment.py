from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.user import UserRead
from app.schemas.sale import SaleRead
class SalePaymentCreate(SQLModel):
    user_id: int
    sale_id: int
    invoice_no: str
    amount: int
    payment_method: str
    reference_no: str
    payment_date: datetime
    note: str
    created_at: datetime
    updated_at: Optional[datetime] = None

class SalePaymentUpdate(SQLModel):
    user_id: Optional[int] = None
    sale_id: Optional[int] = None
    invoice_no: Optional[str] = None
    amount: Optional[int] = None
    payment_method: Optional[str] = None
    reference_no: Optional[str] = None
    payment_date: Optional[datetime] = None
    note: Optional[str] = None
    updated_at: Optional[datetime] = None

class SalePaymentRead(SQLModel):
    user: UserRead
    sale: SaleRead
    invoice_no: str
    amount: int
    payment_method: str
    reference_no: str
    payment_date: datetime
    note: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
