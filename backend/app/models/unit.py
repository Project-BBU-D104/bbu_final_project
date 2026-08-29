from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List, TYPE_CHECKING
from datetime import datetime

if TYPE_CHECKING:
    from app.models.product import Product

class Unit(SQLModel, table=True):
    __tablename__ = "unit"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    short_name: str
    status: bool = True
    description: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    products: List["Product"] = Relationship(back_populates="unit")