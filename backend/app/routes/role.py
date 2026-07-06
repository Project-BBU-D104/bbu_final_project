from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.role import RoleCreate, RoleRead, RoleUpdate
from app.crud.role import  create_role, get_all_role, get_role, update_role, delete_role

router = APIRouter(prefix="/role", tags=["role"])

@router.post("/", response_model=RoleRead)
def create_new_role(role: RoleCreate, session: Session = Depends(get_session)):
    return create_role(session, role)

@router.get("/", response_model=list[RoleRead])
def read_all_role(session: Session = Depends(get_session)):
    return get_all_role(session)

@router.get("/{role_id}", response_model=RoleRead)
def read_role(role_id: int, session: Session = Depends(get_session)):
    return get_role(session, role_id)

@router.put("/{role_id}", response_model=RoleRead)
def update_role_route(role_id: int, role: RoleUpdate, session: Session = Depends(get_session)):
    return update_role(session, role_id, role)

@router.delete("/{category_id}")
def delete_role_route(role_id: int, session: Session = Depends(get_session)):
    return delete_role(session, role_id)