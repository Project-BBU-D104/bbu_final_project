from sqlmodel import SQLModel
from typing import Optional
from datetime import datetime

from app.schemas.role.role import RoleSimple

class UserCreate(SQLModel):
    name: str
    email: str
    password: str
    is_active: bool
    role_id: int
    phone: Optional[str]
    photo: Optional[str]

class UserRead(SQLModel):
    id: Optional[int] = None
    name: str
    email: str
    is_active: bool
    role: RoleSimple
    phone: Optional[str]
    photo: Optional[str]
    created_at: Optional[datetime] = None

class UserSimple(SQLModel):
    id: Optional[int] = None
    name: str