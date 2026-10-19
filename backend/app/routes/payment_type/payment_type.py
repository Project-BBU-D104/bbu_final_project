from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.payment_type.payment_type import PaymentTypeCreate, PaymentTypeRead, PaymentTypeUpdate
from app.crud.payment_type.payment_type import  create_payment_type, get_all_payment_type, get_payment_type, update_payment_type, delete_payment_type

router = APIRouter(prefix="/payment_type", tags=["payment_type"])

CACHE_NS = "payment_type"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=PaymentTypeRead)
async def create_new_payment_type(payment_type: PaymentTypeCreate, session: Session = Depends(get_session)):
    result = create_payment_type(session, payment_type)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[PaymentTypeRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_payment_type(session: Session = Depends(get_session)):
    return get_all_payment_type(session)

@router.get("/{payment_type_id}", response_model=PaymentTypeRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_payment_type(payment_type_id: int, session: Session = Depends(get_session)):
    return get_payment_type(session, payment_type_id)

@router.put("/{payment_type_id}", response_model=PaymentTypeRead)
async def update_payment_type_route(payment_type_id: int, payment_type: PaymentTypeUpdate, session: Session = Depends(get_session)):
    result = update_payment_type(session, payment_type_id, payment_type)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{payment_type_id}")
async def delete_payment_type_route(payment_type_id: int, session: Session = Depends(get_session)):
    result = delete_payment_type(session, payment_type_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result