from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase_payment import PurchasePaymentCreate, PurchasePaymentRead, PurchasePaymentUpdate
from app.crud.purchase.purchase_payment import  create_purchase_payment, get_all_purchase_payment, get_purchase_payment, update_purchase_payment, delete_purchase_payment

router = APIRouter(prefix="/purchase_payment", tags=["purchase_payment"])

@router.post("/", response_model=PurchasePaymentRead)
def create_new_purchase_payment(purchase_payment: PurchasePaymentCreate, session: Session = Depends(get_session)):
    return create_purchase_payment(session, purchase_payment)

@router.get("/", response_model=list[PurchasePaymentRead])
def read_all_purchase_payment(session: Session = Depends(get_session)):
    return get_all_purchase_payment(session)

@router.get("/{purchase_payment_id}", response_model=PurchasePaymentRead)
def read_purchase_payment(purchase_payment_id: int, session: Session = Depends(get_session)):
    return get_purchase_payment(session, purchase_payment_id)

@router.put("/{purchase_payment_id}", response_model=PurchasePaymentRead)
def update_purchase_payment_route(purchase_payment_id: int, purchase_payment: PurchasePaymentUpdate, session: Session = Depends(get_session)):
    return update_purchase_payment(session, purchase_payment_id, purchase_payment)

@router.delete("/{purchase_payment_id}")
def delete_purchase_payment_route(purchase_payment_id: int, session: Session = Depends(get_session)):
    return delete_purchase_payment(session, purchase_payment_id)