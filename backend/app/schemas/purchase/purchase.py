from datetime import datetime
from sqlmodel import SQLModel
from typing import List, Optional

from app.schemas.user.user import UserSimple
from app.schemas.supplier.supplier import SupplierSimple
from app.schemas.purchase.purchase_item import PurchaseItemRead
from app.schemas.warehouse.warehouse_base import WarehouseSimple
from app.schemas.purchase.purchase_item import PurchaseItemCreate

from decimal import Decimal

class PurchaseCreate(SQLModel):
    user_id: int
    supplier_id: int
    warehouse_id: int
    invoice_no: Optional[str] = None
    purchase_date: datetime
    subtotal: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    paid_amount: Decimal
    due_amount: Decimal
    items: List[PurchaseItemCreate]
    payment_status: str = "unpaid"
    status: str = "completed"
    description: Optional[str] = None

class PurchaseUpdate(SQLModel):
    user_id: Optional[int] = None
    supplier_id: Optional[int] = None
    warehouse_id: Optional[int] = None
    invoice_no: Optional[str] = None
    purchase_date: Optional[datetime] = None
    subtotal: Optional[Decimal] = None
    tax_amount: Optional[Decimal] = None
    discount_amount: Optional[Decimal] = None
    total_amount: Optional[Decimal] = None
    paid_amount: Optional[Decimal] = None
    due_amount: Optional[Decimal] = None
    payment_status: Optional[str] = None
    status: Optional[str] = None
    description: Optional[str] = None
    items: Optional[List[PurchaseItemCreate]] = None
    updated_at: Optional[datetime] = None


class PurchaseRead(SQLModel):
    id: Optional[int] = None
    user: UserSimple
    supplier: SupplierSimple
    warehouse: WarehouseSimple
    purchase_items: List[PurchaseItemRead] = []
    invoice_no: str
    purchase_date: datetime
    subtotal: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    paid_amount: Decimal
    due_amount: Decimal
    payment_status: str
    status: str
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at : Optional[datetime] = None

class PurchaseSimple(SQLModel):
    id: Optional[int] = None
    invoice_no: str