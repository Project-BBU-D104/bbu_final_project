from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.currency import Currency
    from app.models.warehouse import Warehouse
    from app.models.payment_type import PaymentType 


class SystemConfiguration(SQLModel, table=True):
    __tablename__ = "system_configuration"

    id: Optional[int] = Field(default=None, primary_key=True)
    company_name: str
    company_address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    logo: Optional[str] = None

    default_currency_id: int = Field(foreign_key="currency.id")
    default_warehouse_id: Optional[int] = Field(default=None,foreign_key="warehouses.id")
    default_payment_type_id: Optional[int] = Field(default=None,foreign_key="payment_type.id")

    allow_discount: bool = True
    tax_enabled : bool = False

    low_stock_warning: Optional[int] = None

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    currency: Optional["Currency"] = Relationship(back_populates="system_configuration")
    warehouses: Optional["Warehouse"] = Relationship(back_populates="system_configuration")
    payment_type: Optional["PaymentType"] = Relationship(back_populates="system_configuration")