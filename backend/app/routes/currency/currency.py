from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.currency.currency import CurrencyCreate, CurrencyRead, CurrencyUpdate
from app.crud.currency.currency import  create_currency, get_all_currency, get_currency, update_currency, delete_currency

router = APIRouter(prefix="/currency", tags=["currency"])

@router.post("/", response_model=CurrencyRead)
def create_new_currency(currency: CurrencyCreate, session: Session = Depends(get_session)):
    return create_currency(session, currency)

@router.get("/", response_model=list[CurrencyRead])
def read_all_currency(session: Session = Depends(get_session)):
    return get_all_currency(session)

@router.get("/{currency_id}", response_model=CurrencyRead)
def read_currency(currency_id: int, session: Session = Depends(get_session)):
    return get_currency(session, currency_id)

@router.put("/{currency_id}", response_model=CurrencyRead)
def update_currency_route(currency_id: int, currency: CurrencyUpdate, session: Session = Depends(get_session)):
    return update_currency(session, currency_id, currency)

@router.delete("/{currency_id}")
def delete_currency_route(currency_id: int, session: Session = Depends(get_session)):
    return delete_currency(session, currency_id)