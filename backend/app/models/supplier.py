from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List
from datetime import datetime

class Supplier(SQLModel, table=True):
    __tablename__ = "supplier"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    phone: str
    email: str
    map: str
    address: str
    status: bool
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    products: List["Product"] = Relationship(back_populates="supplier")
    purchases: List["Purchase"] = Relationship(back_populates="supplier")