from sqlmodel import Session, select
from app.models.audit_logs import AuditLogs
from app.schemas.audit_logs.audit_logs import AuditLogsCreate, AuditLogsUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_audit_logs(session: Session, audit_logs: AuditLogsCreate):
    db_audit_logs = AuditLogs.model_validate(audit_logs)
    session.add(db_audit_logs)
    session.commit()
    session.refresh(db_audit_logs)
    return db_audit_logs

def get_all_audit_logs(session: Session):
    statement = (
        select(AuditLogs)
        .options(
            selectinload(AuditLogs.user)
        )
    )
    return session.exec(statement).all()

def get_audit_logs(session: Session, audit_logs_id: int):
    statement = (
        select(AuditLogs)
        .where(AuditLogs.id == audit_logs_id)
        .options(
            selectinload(AuditLogs.user)
        )
    )
    return session.exec(statement).first()

def update_audit_logs(session: Session, audit_logs_id: int, audit_logs: AuditLogsUpdate):
    db_audit_logs = session.get(AuditLogs, audit_logs_id)
    if db_audit_logs:
        if audit_logs.user_id is not None:
            db_audit_logs.user_id = audit_logs.user_id
        if audit_logs.title is not None:
            db_audit_logs.title = audit_logs.title
        if audit_logs.action is not None:
            db_audit_logs.action = audit_logs.action
        if audit_logs.table_name is not None:
            db_audit_logs.table_name = audit_logs.table_name
        if audit_logs.record_id is not None:
            db_audit_logs.record_id = audit_logs.record_id
        if audit_logs.old_value is not None:
            db_audit_logs.old_value = audit_logs.old_value
        if audit_logs.new_value is not None:
            db_audit_logs.new_value = audit_logs.new_value

        db_audit_logs.updated_at = audit_logs.updated_at or datetime.utcnow()
        session.add(db_audit_logs)
        session.commit()
        session.refresh(db_audit_logs)
    return db_audit_logs

def delete_audit_logs(session: Session, audit_logs_id: int):
    audit_logs = session.get(AuditLogs, audit_logs_id)
    if audit_logs:
        session.delete(audit_logs)
        session.commit()
    return audit_logs