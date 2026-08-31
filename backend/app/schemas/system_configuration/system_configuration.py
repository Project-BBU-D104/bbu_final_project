from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

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
    company_name: str
    company_address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    logo: Optional[str] = None
    default_currency_id : int
    default_warehouse_id: Optional[int] = None
    default_payment_type_id: Optional[int] = None
    allow_discount: Optional[bool] = True
    tax_enabled : Optional[bool] = False
    low_stock_warning: Optional[int] = None
    updated_at: Optional[datetime] = None