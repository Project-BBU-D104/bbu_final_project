from sqlmodel import SQLModel
from typing import Optional
from datetime import datetime

class UserCreate(SQLModel):
    name: str
    email: str
    password: str
    role_id: int
    phone: Optional[str]
    photo: Optional[str]


class UserRead(SQLModel):
    id: Optional[int] = None
    name: str
    email: str
    role_id: int
    phone: Optional[str]
    photo: Optional[str]
    created_at: Optional[datetime] = None
