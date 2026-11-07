from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.sale import Sale
from app.models.sale_payment import SalePayment
from app.schemas.sale.sale_payment import SalePaymentCreate, SalePaymentUpdate
from app.crud.sale.sale import _set_sale_totals
from datetime import datetime, timezone
from decimal import Decimal
from sqlalchemy.orm import selectinload


def _sale_payment_total(session: Session, sale_id: int) -> Decimal:
    payments = session.exec(
        select(SalePayment).where(SalePayment.sale_id == sale_id)
    ).all()
    return sum((Decimal(str(p.amount)) for p in payments), Decimal("0.00"))


def _recalculate_sale(session: Session, sale_id: int) -> None:
    sale = session.get(Sale, sale_id)
    if sale is None:
        raise HTTPException(status_code=404, detail="Sale not found.")
    # shortcut: payment rows are the only source of paid_amount; a sale created
    # with paid_amount but no payment row loses it on the first payment.
    sale.paid_amount = _sale_payment_total(session, sale_id)
    _set_sale_totals(sale)
    sale.updated_at = datetime.now(timezone.utc)
    session.add(sale)


def create_sale_payment(session: Session, sale: SalePaymentCreate):
    db_sale_payment = SalePayment.model_validate(sale.model_dump(exclude_none=True))
    if session.get(Sale, db_sale_payment.sale_id) is None:
        raise HTTPException(status_code=404, detail="Sale not found.")
    try:
        session.add(db_sale_payment)
        session.flush()
        _recalculate_sale(session, db_sale_payment.sale_id)
        session.commit()
        session.refresh(db_sale_payment)
    except Exception:
        session.rollback()
        raise
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
        old_sale_id = db_sale_payment.sale_id
        if sale_item.sale_id is not None:
            if session.get(Sale, sale_item.sale_id) is None:
                raise HTTPException(status_code=404, detail="Sale not found.")
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

        db_sale_payment.updated_at = sale_item.updated_at or datetime.now(timezone.utc)
        session.add(db_sale_payment)
        session.flush()
        _recalculate_sale(session, old_sale_id)
        if db_sale_payment.sale_id != old_sale_id:
            _recalculate_sale(session, db_sale_payment.sale_id)
        session.commit()
        session.refresh(db_sale_payment)
    return db_sale_payment

def delete_sale_payment(session: Session, sale_payment_id: int):
    sale_payment = session.get(SalePayment, sale_payment_id)
    if sale_payment:
        sale_id = sale_payment.sale_id
        session.delete(sale_payment)
        session.flush()
        _recalculate_sale(session, sale_id)
        session.commit()
    return sale_payment