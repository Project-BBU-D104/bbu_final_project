from sqlmodel import Session, select
from app.models.sale import Sale
from app.schemas.sale import SaleCreate, SaleUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_sale(session: Session, sale: SaleCreate):
    db_sale = sale.model_validate(sale)
    session.add(db_sale)
    session.commit()
    session.refresh(db_sale)
    return db_sale

def get_all_sales(session: Session):
    statement = (
        select(Sale)
        .options(
            selectinload(Sale.user),
            selectinload(Sale.customer)
        )
    )
    return session.exec(statement).all()

def get_sale(session: Session, sale_id: int):
    statement = (
        select(Sale)
        .where(Sale.id == sale_id)
        .options(
            selectinload(Sale.user),
            selectinload(Sale.customer)
        )
    )
    return session.exec(statement).first()

def update_sale(session: Session, sale_id: int, sale: SaleUpdate):
    db_sale = session.get(Sale, sale_id)
    if db_sale:
        if sale.customer_id is not None:
            db_sale.customer_id = sale.customer_id
        if sale.user_id is not None:
            db_sale.user_id = sale.user_id
        if sale.invoice_no is not None:
            db_sale.invoice_no = sale.invoice_no
        if sale.sale_date is not None:
            db_sale.sale_date = sale.sale_date
        if sale.subtotal is not None:
            db_sale.subtotal = sale.subtotal
        if sale.tax_amount is not None:
            db_sale.tax_amount = sale.tax_amount
        if sale.discount_amount is not None:
            db_sale.discount_amount = sale.discount_amount
        if sale.total_amount is not None:
            db_sale.total_amount = sale.total_amount
        if sale.paid_amount is not None:
            db_sale.paid_amount = sale.paid_amount
        if sale.due_amount is not None:
            db_sale.due_amount = sale.due_amount
        if sale.payment_status is not None:
            db_sale.payment_status = sale.payment_status
        if sale.status is not None:
            db_sale.status = sale.status
        if sale.payment_method is not None:
            db_sale.payment_method = sale.payment_method

        db_sale.updated_at = sale.updated_at or datetime.utcnow()
        session.add(db_sale)
        session.commit()
        session.refresh(db_sale)
    return db_sale

def delete_sale(session: Session, sale_id: int):
    sale = session.get(Sale, sale_id)
    if sale:
        session.delete(sale)
        session.commit()
    return sale