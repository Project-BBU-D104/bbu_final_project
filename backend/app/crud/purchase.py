from sqlmodel import Session, select
from app.models.purchase import Purchase
from app.schemas.purchase import PurchaseCreate, PurchaseUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_purchase(session: Session, purchase: PurchaseCreate):
    db_purchase = Purchase.model_validate(purchase)
    session.add(db_purchase)
    session.commit()
    session.refresh(db_purchase)
    return db_purchase

def get_all_purchases(session: Session):
    statement = (
        select(Purchase)
        .options(
            selectinload(Purchase.user),
            selectinload(Purchase.supplier)
        )
    )
    return session.exec(statement).all()

def get_purchase(session: Session, purchase_id: int):
    statement = (
        select(Purchase)
        .where(Purchase.id == purchase_id)
        .options(
            selectinload(Purchase.user),
            selectinload(Purchase.supplier)
        )
    )
    return session.exec(statement).first()

def update_purchase(session: Session, purchase_id: int, purchase: PurchaseUpdate):
    db_purchase = session.get(Purchase, purchase_id)
    if db_purchase:
        if purchase.supplier_id is not None:
            db_purchase.supplier_id = purchase.supplier_id
        if purchase.user_id is not None:
            db_purchase.user_id = purchase.user_id
        if purchase.invoice_no is not None:
            db_purchase.invoice_no = purchase.invoice_no
        if purchase.purchase_date is not None:
            db_purchase.purchase_date = purchase.purchase_date
        if purchase.subtotal is not None:
            db_purchase.subtotal = purchase.subtotal
        if purchase.tax_amount is not None:
            db_purchase.tax_amount = purchase.tax_amount
        if purchase.discount_amount is not None:
            db_purchase.discount_amount = purchase.discount_amount
        if purchase.total_amount is not None:
            db_purchase.total_amount = purchase.total_amount
        if purchase.paid_amount is not None:
            db_purchase.paid_amount = purchase.paid_amount
        if purchase.due_amount is not None:
            db_purchase.due_amount = purchase.due_amount
        if purchase.payment_status is not None:
            db_purchase.payment_status = purchase.payment_status
        if purchase.status is not None:
            db_purchase.status = purchase.status

        db_purchase.updated_at = purchase.updated_at or datetime.utcnow()
        session.add(db_purchase)
        session.commit()
        session.refresh(db_purchase)
    return db_purchase

def delete_purchase(session: Session, purchase_id: int):
    purchase = session.get(Purchase, purchase_id)
    if purchase:
        session.delete(purchase)
        session.commit()
    return purchase