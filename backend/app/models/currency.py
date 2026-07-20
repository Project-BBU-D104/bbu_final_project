from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List
from datetime import datetime

class Currency(SQLModel, table=True):
    __tablename__ = "currency"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    code: str = Field(unique=True, index=True)
    symbol: str
    exchange_rate: float
    is_default: bool = False
    status: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

