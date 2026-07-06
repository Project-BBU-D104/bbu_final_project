from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, List,TYPE_CHECKING
from datetime import datetime
from app.models.user import User
from app.models.supplier import Supplier

if TYPE_CHECKING:
    from app.models.purchase_item import PurchaseItem


class Purchase(SQLModel, table=True):
    __tablename__ = "purchases"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    supplier_id: int = Field(foreign_key="supplier.id")
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
    deleted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    user: Optional[User] = Relationship(back_populates="purchases")
    supplier: Optional[Supplier] = Relationship(back_populates="purchases")
    purchase_items: List["PurchaseItem"] = Relationship(back_populates="purchase")