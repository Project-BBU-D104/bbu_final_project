from sqlmodel import SQLModel, Field,Relationship
from typing import Optional,List
from datetime import datetime

class Role(SQLModel, table=True):
    __tablename__ = "role"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None
    is_active: Optional[bool] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)