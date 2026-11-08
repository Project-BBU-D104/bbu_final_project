from sqlmodel import Field, SQLModel
from typing import Optional
from datetime import datetime
from pydantic import field_validator

from app.schemas.role.role import RoleSimple

class UserCreate(SQLModel):
    name: str
    email: str
    password: str
    is_active: bool
    role_id: int
    system_configuration_id: Optional[int] = None
    phone: Optional[str]
    photo: Optional[str]

class UserRead(SQLModel):
    id: Optional[int] = None
    name: str
    email: str
    is_active: bool
    role: RoleSimple
    system_configuration_id: Optional[int] = None
    phone: Optional[str]
    photo: Optional[str]
    created_at: Optional[datetime] = None

class UserSimple(SQLModel):
    id: Optional[int] = None
    name: str

class ProfileUpdate(SQLModel):
    name: str
    email: str
    phone: Optional[str] = None
    photo: Optional[str] = None

    @field_validator("name")
    @classmethod
    def trim_name(cls, value: str) -> str:
        trimmed = value.strip()
        if not trimmed:
            raise ValueError("Name cannot be blank")
        return trimmed

class ProfileRead(SQLModel):
    id: Optional[int] = None
    name: str
    email: str
    phone: Optional[str] = None
    photo: Optional[str] = None

class PasswordChange(SQLModel):
    current_password: str
    new_password: str = Field(min_length=8)