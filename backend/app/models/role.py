from sqlmodel import SQLModel, Field,Relationship
from typing import TYPE_CHECKING, Optional,List
from datetime import datetime,timezone

if TYPE_CHECKING:
    from app.models.user import User

class Role(SQLModel, table=True):
    __tablename__ = "role"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None
    is_active: Optional[bool] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    users: List["User"] = Relationship(back_populates="role")