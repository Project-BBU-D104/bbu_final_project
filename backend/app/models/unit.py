from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List, TYPE_CHECKING
from datetime import datetime, timezone

if TYPE_CHECKING:
    from app.models.product import Product

class Unit(SQLModel, table=True):
    __tablename__ = "unit"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    short_name: str
    status: bool = True
    description: Optional[str] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    products: List["Product"] = Relationship(back_populates="unit")