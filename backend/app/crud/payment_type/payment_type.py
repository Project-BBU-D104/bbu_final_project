from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.payment_type import PaymentType
from app.schemas.payment_type.payment_type import PaymentTypeCreate, PaymentTypeUpdate
from datetime import datetime

def create_payment_type(session: Session, payment_type: PaymentTypeCreate):
    existing = session.exec(
        select(PaymentType).where(PaymentType.name == payment_type.name)
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Payment type name already exists."
        )
    
    db_payment_type = PaymentType.from_orm(payment_type)
    session.add(db_payment_type)
    session.commit()
    session.refresh(db_payment_type)

    return db_payment_type

def get_all_payment_type(session: Session):
    return session.exec(select(PaymentType)).all()

def get_payment_type(session: Session, payment_type_id: int):
    return session.get(PaymentType, payment_type_id)

def update_payment_type(session: Session, payment_type_id: int, payment_type: PaymentTypeUpdate):
    if not session.get(PaymentType, payment_type_id):
        raise HTTPException(
            status_code=404,
            detail="Payment type not found."
        )
    
    db_payment_type = session.get(PaymentType, payment_type_id)
    if db_payment_type:
        if payment_type.name is not None:
            db_payment_type.name = payment_type.name
        if payment_type.description is not None:
            db_payment_type.description = payment_type.description
        if payment_type.status is not None:
            db_payment_type.status = payment_type.status

        db_payment_type.updated_at = payment_type.updated_at or datetime.utcnow()
        session.add(db_payment_type)
        session.commit()
        session.refresh(db_payment_type)
    return db_payment_type

def delete_payment_type(session: Session, payment_type_id: int):
    if not session.get(PaymentType, payment_type_id):
        raise HTTPException(
            status_code=404,
            detail="Payment type not found."
        )
    
    payment_type = session.get(PaymentType, payment_type_id)

    if payment_type:
        session.delete(payment_type)
        session.commit()
    return {
        "message": "Payment type deleted successfully",
        "payment_type": payment_type
    }