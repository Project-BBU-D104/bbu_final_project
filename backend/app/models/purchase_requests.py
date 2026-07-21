from sqlmodel import SQLModel, Field,Relationship
from typing import Optional, TYPE_CHECKING, List
from datetime import datetime

if TYPE_CHECKING:
    from app.models.warehouse import Warehouse
    from app.models.purchase_request_items import PurchaseRequestItems

class PurchaseRequest(SQLModel, table=True):
    __tablename__ = "purchase_requests"

    id: Optional[int] = Field(default=None, primary_key=True)
    warehouse_id: int = Field(foreign_key="warehouses.id")
    request_no: str
    request_type: str
    requested_by: str
    approved_by: str
    status: str
    reason: str
    request_date: datetime
    approved_date: datetime
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
 
    warehouse: Optional["Warehouse"] = Relationship(back_populates="purchase_requests")

     # ADD THIS
    purchase_request_items: List["PurchaseRequestItems"] = Relationship(
        back_populates="purchase_request"
    )