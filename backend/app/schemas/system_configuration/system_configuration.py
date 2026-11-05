from datetime import datetime
from pydantic import Field
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.currency.currency import CurrencySimple
from app.schemas.payment_type.payment_type import PaymentTypeSimple
from app.schemas.warehouse.warehouse_base import WarehouseSimple

class SystemConfigurationCreate(SQLModel):
    company_name: str
    company_address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    logo: Optional[str] = None
    default_currency_id : int
    default_warehouse_id: Optional[int] = None
    default_payment_type_id: Optional[int] = None
    allow_discount: bool = True
    tax_enabled : bool = False
    low_stock_warning: Optional[int] = None

class SystemConfigurationUpdate(SQLModel):
    company_name: Optional[str] = None
    company_address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    logo: Optional[str] = None
    default_currency_id : Optional[int]
    default_warehouse_id: Optional[int] = None
    default_payment_type_id: Optional[int] = None
    allow_discount: Optional[bool] = True
    tax_enabled : Optional[bool] = False
    low_stock_warning: Optional[int] = None
    updated_at: Optional[datetime] = None

class SystemConfigurationRead(SQLModel):
    id: Optional[int] = None
    company_name: str
    company_address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    logo: Optional[str] = None
    default_currency: Optional[CurrencySimple] = Field(
        default=None,
        validation_alias="currency"
    )
    default_warehouse: Optional[WarehouseSimple] = Field(
        default=None,
        validation_alias="warehouse"
    )
    default_payment_type: Optional[PaymentTypeSimple] = Field(
        default=None,
        validation_alias="payment_type"
    )
    allow_discount: Optional[bool] = True
    tax_enabled : Optional[bool] = False
    low_stock_warning: Optional[int] = None
    updated_at: Optional[datetime] = None