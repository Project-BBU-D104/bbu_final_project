from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.unit import UnitCreate, UnitRead, UnitUpdate
from app.crud.unit import  create_unit, get_all_unit, get_unit, update_unit, delete_unit

router = APIRouter(prefix="/unit", tags=["unit"])

@router.post("/", response_model=UnitRead)
def create_new_unit(unit: UnitCreate, session: Session = Depends(get_session)):
    return create_unit(session, unit)

@router.get("/", response_model=list[UnitRead])
def read_all_unit(session: Session = Depends(get_session)):
    return get_all_unit(session)

@router.get("/{unit_id}", response_model=UnitRead)
def read_unit(unit_id: int, session: Session = Depends(get_session)):
    return get_unit(session, unit_id)

@router.put("/{unit_id}", response_model=UnitRead)
def update_unit_route(unit_id: int, unit: UnitUpdate, session: Session = Depends(get_session)):
    return update_unit(session, unit_id, unit)

@router.delete("/{unit_id}")
def delete_unit_route(unit_id: int, session: Session = Depends(get_session)):
    return delete_unit(session, unit_id)