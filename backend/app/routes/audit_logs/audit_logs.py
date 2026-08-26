from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.audit_logs.audit_logs import AuditLogsCreate, AuditLogsRead, AuditLogsUpdate
from app.crud.audit_logs.audit_logs import create_audit_logs, get_all_audit_logs, get_audit_logs, update_audit_logs, delete_audit_logs

router = APIRouter(prefix="/audit_logs", tags=["audit_logs"])

@router.post("/", response_model=AuditLogsRead)
def create_new_audit_logs(audit_logs: AuditLogsCreate, session: Session = Depends(get_session)):
    return create_audit_logs(session, audit_logs)

@router.get("/", response_model=list[AuditLogsRead])
def read_all_audit_logs(session: Session = Depends(get_session)):
    return get_all_audit_logs(session)

@router.get("/{audit_logs_id}", response_model=AuditLogsRead)
def read_audit_logs_id(audit_logs_id: int, session: Session = Depends(get_session)):
    return get_audit_logs(session, audit_logs_id)

@router.put("/{audit_logs_id}", response_model=AuditLogsRead)
def update_audit_logs_route(audit_logs_id: int, audit_logs: AuditLogsUpdate, session: Session = Depends(get_session)):
    return update_audit_logs(session, audit_logs_id, audit_logs)

@router.delete("/{audit_logs_id}")
def delete_audit_logs_route(audit_logs_id: int, session: Session = Depends(get_session)):
    return delete_audit_logs(session, audit_logs_id)