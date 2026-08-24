from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

class RoleCreate(SQLModel):
    name: str
    description: Optional[str] = None
    is_active: bool

class RoleUpdate(SQLModel):
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None
    updated_at: Optional[datetime] = None

class RoleRead(SQLModel):
    id: Optional[int] = None
    name: str
    description: Optional[str] = None
    is_active: Optional[bool] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class RoleSimple(SQLModel):
    id: Optional[int] = None
    name: str