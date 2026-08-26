from datetime import datetime
from sqlmodel import SQLModel
from typing import Optional

from app.schemas.user.user import UserRead

class AuditLogsCreate(SQLModel):
    user_id: int
    title: str
    action: str
    table_name: str
    record_id: int
    old_value: str
    new_value: str
    created_at: datetime
    updated_at: Optional[datetime] = None

class AuditLogsUpdate(SQLModel):
    user_id: Optional[int] = None
    title: Optional[str] = None
    action: Optional[str] = None
    table_name: Optional[str] = None
    record_id: Optional[int] = None
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    updated_at: Optional[datetime] = None

class AuditLogsRead(SQLModel):
    id: Optional[int] = None
    user: Optional[UserRead] = None
    title: str
    action: str
    table_name: str
    record_id: int
    old_value: str
    new_value: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None