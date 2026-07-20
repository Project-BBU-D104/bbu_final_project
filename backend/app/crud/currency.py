from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.currency import Currency
from app.schemas.currency import CurrencyCreate, CurrencyUpdate
from datetime import datetime

def create_currency(session: Session, currency: CurrencyCreate):
    existing = session.exec(
        select(Currency).where(Currency.name == currency.name)
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Currency name already exists."
        )
    
    db_currency = Currency.from_orm(currency)
    session.add(db_currency)
    session.commit()
    session.refresh(db_currency)

    return db_currency

def get_all_currency(session: Session):
    return session.exec(select(Currency)).all()

def get_currency(session: Session, currency_id: int):
    return session.get(Currency, currency_id)

def update_currency(session: Session, currency_id: int, currency: CurrencyUpdate):
    if not session.get(Currency, currency_id):
        raise HTTPException(
            status_code=404,
            detail="Currency not found."
        )
    
    db_currency = session.get(Currency, currency_id)
    if db_currency:
        if currency.name is not None:
            db_currency.name = currency.name
        if currency.code is not None:
            db_currency.code = currency.code
        if currency.symbol is not None:
            db_currency.symbol = currency.symbol
        if currency.exchange_rate is not None:
            db_currency.exchange_rate = currency.exchange_rate
        if currency.is_default is not None:
            db_currency.is_default = currency.is_default
        if currency.status is not None:
            db_currency.status = currency.status

        db_currency.updated_at = currency.updated_at or datetime.utcnow()
        session.add(db_currency)
        session.commit()
        session.refresh(db_currency)
    return db_currency

def delete_currency(session: Session, currency_id: int):
    if not session.get(Currency, currency_id):
        raise HTTPException(
            status_code=404,
            detail="Currency not found."
        )
    
    currency = session.get(Currency, currency_id)

    if currency:
        session.delete(currency)
        session.commit()
    return {
        "message": "Currency deleted successfully",
        "currency": currency
    }