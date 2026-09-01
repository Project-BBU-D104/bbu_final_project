from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,TYPE_CHECKING
from datetime import datetime
from app.models.user import User
from app.models.supplier import Supplier

from decimal import Decimal
from sqlalchemy import Numeric

if TYPE_CHECKING:
    from app.models.purchase_item import PurchaseItem
    from app.models.warehouse import Warehouse
    from app.models.purchase_payment import PurchasePayment

class Purchase(SQLModel, table=True):
    __tablename__ = "purchases"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    supplier_id: int = Field(foreign_key="supplier.id")
    warehouse_id: int = Field(foreign_key="warehouses.id")
    invoice_no: str
    purchase_date: datetime
    subtotal: Decimal = Field(sa_column=Numeric(10, 2))
    tax_amount: Decimal = Field(sa_column=Numeric(10, 2))
    discount_amount: Decimal = Field(sa_column=Numeric(10, 2))
    total_amount: Decimal = Field(sa_column=Numeric(10, 2))
    paid_amount: Decimal = Field(sa_column=Numeric(10, 2))
    due_amount: Decimal = Field(sa_column=Numeric(10, 2))
    payment_status: str
    status: str
    deleted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    user: Optional[User] = Relationship(back_populates="purchases")
    supplier: Optional[Supplier] = Relationship(back_populates="purchases")
    purchase_items: list["PurchaseItem"] = Relationship(
        back_populates="purchase",
        sa_relationship_kwargs={
            "cascade": "all, delete-orphan"
        }
    )
    warehouse: Optional["Warehouse"] = Relationship(back_populates="purchases")

    purchase_payments: Optional["PurchasePayment"] = Relationship(
        back_populates="purchase"
    )