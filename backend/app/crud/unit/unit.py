from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.unit import Unit
from app.schemas.unit.unit import UnitCreate, UnitUpdate
from datetime import datetime

def create_unit(session: Session, unit: UnitCreate):
    existing = session.exec(
        select(Unit).where(Unit.name == unit.name)
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Unit name already exists."
        )
    
    db_unit = Unit.from_orm(unit)
    session.add(db_unit)
    session.commit()
    session.refresh(db_unit)

    return db_unit

def get_all_unit(session: Session):
    return session.exec(select(Unit)).all()

def get_unit(session: Session, unit_id: int):
    return session.get(Unit, unit_id)

def update_unit(session: Session, unit_id: int, unit: UnitUpdate):
    if not session.get(Unit, unit_id):
        raise HTTPException(
            status_code=404,
            detail="Payment type not found."
        )
    
    db_unit = session.get(Unit, unit_id)
    if db_unit:
        if unit.name is not None:
            db_unit.name = unit.name
        if unit.short_name is not None:
            db_unit.short_name = unit.short_name
        if unit.description is not None:
            db_unit.description = unit.description
        if unit.status is not None:
            db_unit.status = unit.status

        db_unit.updated_at = unit.updated_at or datetime.utcnow()
        session.add(db_unit)
        session.commit()
        session.refresh(db_unit)
    return db_unit

def delete_unit(session: Session, unit_id: int):
    if not session.get(Unit, unit_id):
        raise HTTPException(
            status_code=404,
            detail="Payment type not found."
        )
    
    unit = session.get(Unit, unit_id)

    if unit:
        session.delete(unit)
        session.commit()
    return {
        "message": "Payment type deleted successfully",
        "unit": unit
    }