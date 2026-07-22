from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional
from pydantic import field_validator

from app.schemas.purchase import PurchaseRead
from app.schemas.supplier import SupplierSimple
from app.schemas.payment_type import PaymentTypeSimple
from app.schemas.currency import CurrencySimple

class PurchasePaymentCreate(SQLModel):
    payment_no: str
    purchase_id: int
    supplier_id: int
    payment_type_id: int
    currency_id: int
    amount: float
    payment_date: datetime
    status: str
    note: Optional[str] = None

class PurchasePaymentUpdate(SQLModel):
    payment_no: Optional[str] = None
    purchase_id: Optional[int] = None
    supplier_id: Optional[int] = None
    payment_type_id: Optional[int] = None
    currency_id: Optional[int] = None
    amount: Optional[float] = None
    payment_date: Optional[datetime] = None
    status: Optional[str] = None
    note: Optional[str] = None
    updated_at: Optional[datetime] = None


class PurchasePaymentRead(SQLModel):
    payment_no: str
    purchase: PurchaseRead
    supplier: SupplierSimple
    payment_type: PaymentTypeSimple
    currency: CurrencySimple
    amount: float
    payment_date: datetime
    status: str
    note: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
