from sqlmodel import SQLModel
from typing import Optional


class UserCreate(SQLModel):
    name: str
    email: str
    password: str


class UserRead(SQLModel):
    id: Optional[int] = None
    name: str
    email: str
