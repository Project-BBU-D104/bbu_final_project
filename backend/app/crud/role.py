from sqlmodel import Session, select
from app.models.role import Role
from app.schemas.role import RoleCreate, RoleUpdate
from datetime import datetime
from fastapi import HTTPException

def create_role(session: Session, role: RoleCreate):
    db_role = Role.from_orm(role)
    session.add(db_role)
    session.commit()
    session.refresh(db_role)
    return db_role

def get_all_role(session: Session):
    return session.exec(select(Role)).all()

def get_role(session: Session, role_id: int):
    return session.get(Role, role_id)

def update_role(session: Session, role_id: int, role: RoleUpdate):
    db_role = session.get(Role, role_id)
    if db_role:
        if role.name is not None:
            db_role.name = role.name
        if role.description is not None:
            db_role.description = role.description
        if role.is_active is not None:
            db_role.is_active = role.is_active

        db_role.updated_at = role.updated_at or datetime.utcnow()
        session.add(db_role)
        session.commit()
        session.refresh(db_role)
    return db_role

def delete_role(session: Session, role_id: int):
    if(not session.get(Role, role_id)):
        raise HTTPException(status_code=404, detail="Role not found")
    role = session.get(Role, role_id)
    if role:
        session.delete(role)
        session.commit()
    return role