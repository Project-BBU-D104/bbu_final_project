from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List
from datetime import datetime

class Customer(SQLModel, table=True):
    __tablename__ = "customers"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    photo: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    description: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)