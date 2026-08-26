from sqlmodel import Session, select
from app.models.sale_payment import SalePayment
from app.schemas.sale.sale_payment import SalePaymentCreate, SalePaymentUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_sale_payment(session: Session, sale: SalePaymentCreate):
    db_sale_payment = sale.model_validate(sale)
    session.add(db_sale_payment)
    session.commit()
    session.refresh(db_sale_payment)
    return db_sale_payment

def get_all_sale_payments(session: Session):
    statement = (
        select(SalePayment)
        .options(
            selectinload(SalePayment.user),
            selectinload(SalePayment.sale)
        )
    )
    return session.exec(statement).all()

def get_sale_payment(session: Session, sale_payment_id: int):
    statement = (
        select(SalePayment)
        .where(SalePayment.id == sale_payment_id)
        .options(
            selectinload(SalePayment.user),
            selectinload(SalePayment.sale)
        )
    )
    return session.exec(statement).first()

def update_sale_payment(session: Session, sale_payment_id: int, sale_item: SalePaymentUpdate):
    db_sale_payment = session.get(SalePayment, sale_payment_id)
    if db_sale_payment:
        if sale_item.sale_id is not None:
            db_sale_payment.sale_id = sale_item.sale_id
        if sale_item.user_id is not None:
            db_sale_payment.user_id = sale_item.user_id
        if sale_item.amount is not None:
            db_sale_payment.amount = sale_item.amount
        if sale_item.payment_method is not None:
            db_sale_payment.payment_method = sale_item.payment_method
        if sale_item.reference_no is not None:
            db_sale_payment.reference_no = sale_item.reference_no
        if sale_item.payment_date is not None:
            db_sale_payment.payment_date = sale_item.payment_date
        if sale_item.note is not None:
            db_sale_payment.note = sale_item.note

        db_sale_payment.updated_at = sale_item.updated_at or datetime.utcnow()
        session.add(db_sale_payment)
        session.commit()
        session.refresh(db_sale_payment)
    return db_sale_payment

def delete_sale_payment(session: Session, sale_payment_id: int):
    sale_payment = session.get(SalePayment, sale_payment_id)
    if sale_payment:
        session.delete(sale_payment)
        session.commit()
    return sale_payment