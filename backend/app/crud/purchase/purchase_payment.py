from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_payment import PurchasePayment
from app.schemas.purchase.purchase_payment import PurchasePaymentCreate, PurchasePaymentUpdate
from datetime import datetime

def create_purchase_payment(session: Session, purchase_payment: PurchasePaymentCreate):
    db_purchase_payment = PurchasePayment.from_orm(purchase_payment)
    session.add(db_purchase_payment)
    session.commit()
    session.refresh(db_purchase_payment)
 
    return db_purchase_payment

def get_all_purchase_payment(session: Session):
    return session.exec(select(PurchasePayment)).all()

def get_purchase_payment(session: Session, purchase_payment_id: int):
    return session.get(PurchasePayment, purchase_payment_id)

def update_purchase_payment(session: Session, purchase_payment_id: int, purchase_payment: PurchasePaymentUpdate):
    if not session.get(PurchasePayment, purchase_payment_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Payment not found."
        )
    
    db_purchase_payment = session.get(PurchasePayment, purchase_payment_id)
    if db_purchase_payment:
        if purchase_payment.payment_no is not None:
            db_purchase_payment.payment_no = purchase_payment.payment_no
        if purchase_payment.purchase_id is not None:
            db_purchase_payment.purchase_id = purchase_payment.purchase_id
        if purchase_payment.supplier_id is not None:
            db_purchase_payment.supplier_id = purchase_payment.supplier_id
        if purchase_payment.payment_type_id is not None:
            db_purchase_payment.payment_type_id = purchase_payment.payment_type_id
        if purchase_payment.currency_id is not None:
            db_purchase_payment.currency_id = purchase_payment.currency_id
        if purchase_payment.amount is not None:
            db_purchase_payment.amount = purchase_payment.amount
        if purchase_payment.payment_date is not None:
            db_purchase_payment.payment_date = purchase_payment.payment_date
        if purchase_payment.note is not None:
            db_purchase_payment.note = purchase_payment.note
        if purchase_payment.status is not None:
            db_purchase_payment.status = purchase_payment.status

        db_purchase_payment.updated_at = purchase_payment.updated_at or datetime.utcnow()
        session.add(db_purchase_payment)
        session.commit()
        session.refresh(db_purchase_payment)
    return db_purchase_payment

def delete_purchase_payment(session: Session, purchase_payment_id: int):
    if not session.get(PurchasePayment, purchase_payment_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Payment not found."
        )
    
    purchase_payment = session.get(PurchasePayment, purchase_payment_id)

    if purchase_payment:
        session.delete(purchase_payment)
        session.commit()
    return {
        "message": "Purchase Payment deleted successfully",
        "purchase_payment": purchase_payment
    }