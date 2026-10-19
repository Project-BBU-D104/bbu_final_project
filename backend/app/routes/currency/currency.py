from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.currency.currency import CurrencyCreate, CurrencyRead, CurrencyUpdate
from app.crud.currency.currency import  create_currency, get_all_currency, get_currency, update_currency, delete_currency

router = APIRouter(prefix="/currency", tags=["currency"])

CACHE_NS = "currency"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=CurrencyRead)
async def create_new_currency(currency: CurrencyCreate, session: Session = Depends(get_session)):
    result = create_currency(session, currency)
    await FastAPICache.clear(namespace=CACHE_NS) 
    return result

@router.get("/", response_model=list[CurrencyRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_currency(session: Session = Depends(get_session)):
    return get_all_currency(session)

@router.get("/{currency_id}", response_model=CurrencyRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_currency(currency_id: int, session: Session = Depends(get_session)):
    return get_currency(session, currency_id)

@router.put("/{currency_id}", response_model=CurrencyRead)
async def update_currency_route(currency_id: int, currency: CurrencyUpdate, session: Session = Depends(get_session)):
    result = update_currency(session, currency_id, currency)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{currency_id}")
async def delete_currency_route(currency_id: int, session: Session = Depends(get_session)):
    result = delete_currency(session, currency_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result