from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.payment_type import PaymentTypeCreate, PaymentTypeRead, PaymentTypeUpdate
from app.crud.payment_type import  create_payment_type, get_all_payment_type, get_payment_type, update_payment_type, delete_payment_type

router = APIRouter(prefix="/payment_type", tags=["payment_type"])

@router.post("/", response_model=PaymentTypeRead)
def create_new_payment_type(payment_type: PaymentTypeCreate, session: Session = Depends(get_session)):
    return create_payment_type(session, payment_type)

@router.get("/", response_model=list[PaymentTypeRead])
def read_all_payment_type(session: Session = Depends(get_session)):
    return get_all_payment_type(session)

@router.get("/{payment_type_id}", response_model=PaymentTypeRead)
def read_payment_type(payment_type_id: int, session: Session = Depends(get_session)):
    return get_payment_type(session, payment_type_id)

@router.put("/{payment_type_id}", response_model=PaymentTypeRead)
def update_payment_type_route(payment_type_id: int, payment_type: PaymentTypeUpdate, session: Session = Depends(get_session)):
    return update_payment_type(session, payment_type_id, payment_type)

@router.delete("/{payment_type_id}")
def delete_payment_type_route(payment_type_id: int, session: Session = Depends(get_session)):
    return delete_payment_type(session, payment_type_id)