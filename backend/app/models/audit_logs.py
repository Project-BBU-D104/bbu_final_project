from sqlmodel import SQLModel, Field,Relationship
from typing import Optional
from datetime import datetime
from app.models.user import User

class AuditLogs(SQLModel, table=True):
    __tablename__ = "audit_logs"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    title: str
    action: str
    table_name: str
    record_id: int
    old_value: str
    new_value: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Many audit logs -> one user
    user: Optional["User"] = Relationship(back_populates="audit_logs")