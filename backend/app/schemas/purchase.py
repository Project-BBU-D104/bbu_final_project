from datetime import datetime
from sqlmodel import SQLModel
from typing import List, Optional

from app.schemas.user import UserSimple
from app.schemas.supplier import SupplierSimple
from app.schemas.purchase_item import PurchaseItemRead
from app.schemas.warehouse_base import WarehouseSimple

class PurchaseCreate(SQLModel):
    user_id: int
    supplier_id: int
    warehouse_id: int
    invoice_no: Optional[str] = None
    purchase_date: datetime
    subtotal: int
    tax_amount: int
    discount_amount: int
    total_amount: int
    paid_amount: int
    due_amount: int
    payment_status: str
    status: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None


class PurchaseUpdate(SQLModel):
    user_id: Optional[int] = None
    supplier_id: Optional[int] = None
    invoice_no: Optional[str] = None
    purchase_date: Optional[datetime] = None
    subtotal: Optional[int] = None
    tax_amount: Optional[int] = None
    discount_amount: Optional[int] = None
    total_amount: Optional[int] = None
    paid_amount: Optional[int] = None
    due_amount: Optional[str] = None
    payment_status: Optional[str] = None
    status: Optional[str] = None
    description: Optional[str] = None
    updated_at: Optional[datetime] = None


class PurchaseRead(SQLModel):
    id: Optional[int] = None
    user: UserSimple
    supplier: SupplierSimple
    warehouse: WarehouseSimple
    purchase_items: List[PurchaseItemRead] = []
    invoice_no: str
    purchase_date: datetime
    subtotal: int
    tax_amount: int
    discount_amount: int
    total_amount: int
    paid_amount: int
    due_amount: int
    payment_status: str
    status: str
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None
