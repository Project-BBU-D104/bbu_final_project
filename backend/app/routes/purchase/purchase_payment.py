from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase_payment import PurchasePaymentCreate, PurchasePaymentRead, PurchasePaymentUpdate
from app.crud.purchase.purchase_payment import  create_purchase_payment, get_all_purchase_payment, get_purchase_payment, update_purchase_payment, delete_purchase_payment

router = APIRouter(prefix="/purchase_payment", tags=["purchase_payment"])

CACHE_NS = "purchase_payment"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=PurchasePaymentRead)
async def create_new_purchase_payment(purchase_payment: PurchasePaymentCreate, session: Session = Depends(get_session)):
    result = create_purchase_payment(session, purchase_payment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[PurchasePaymentRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_purchase_payment(session: Session = Depends(get_session)):
    return get_all_purchase_payment(session)

@router.get("/{purchase_payment_id}", response_model=PurchasePaymentRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_purchase_payment(purchase_payment_id: int, session: Session = Depends(get_session)):
    return get_purchase_payment(session, purchase_payment_id)

@router.put("/{purchase_payment_id}", response_model=PurchasePaymentRead)
async def update_purchase_payment_route(purchase_payment_id: int, purchase_payment: PurchasePaymentUpdate, session: Session = Depends(get_session)):
    result = update_purchase_payment(session, purchase_payment_id, purchase_payment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{purchase_payment_id}")
async def delete_purchase_payment_route(purchase_payment_id: int, session: Session = Depends(get_session)):
    result = delete_purchase_payment(session, purchase_payment_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result