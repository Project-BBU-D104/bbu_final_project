from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.sale_payment import SalePaymentCreate,SalePaymentRead,SalePaymentUpdate
from app.crud.sale_payment import create_sale_payment, get_all_sale_payments, get_sale_payment, update_sale_payment, delete_sale_payment

router = APIRouter(prefix="/sale_payment", tags=["sale_payment"])

@router.post("/", response_model=SalePaymentRead)
def create_new_sale(sale_payment: SalePaymentCreate, session: Session = Depends(get_session)):
    return create_sale_payment(session, sale_payment)

@router.get("/", response_model=list[SalePaymentRead])
def read_sale_payments(session: Session = Depends(get_session)):
    return get_all_sale_payments(session)

@router.get("/{sale_payment_id}", response_model=SalePaymentRead)
def read_sale_payment(sale_payment_id: int, session: Session = Depends(get_session)):
    return get_sale_payment(session, sale_payment_id)

@router.put("/{sale_payment_id}", response_model=SalePaymentRead)
def update_sale_payment_route(sale_payment_id: int, sale: SalePaymentUpdate, session: Session = Depends(get_session)):
    return update_sale_payment(session, sale_payment_id, sale)

@router.delete("/{sale_payment_id}")
def delete_sale_payment_route(sale_payment_id: int, session: Session = Depends(get_session)):
    return delete_sale_payment(session, sale_payment_id)