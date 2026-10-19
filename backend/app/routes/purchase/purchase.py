from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase import PurchaseCreate,PurchaseRead,PurchaseUpdate,PurchaseSimple
from app.crud.purchase.purchase import  create_purchase, get_all_purchases,get_recent_purchases, get_purchase, update_purchase, delete_purchase

router = APIRouter(prefix="/purchase", tags=["purchase"])

CACHE_NS = "purchase"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=PurchaseRead)
async def create_new_purchase(purchase: PurchaseCreate, session: Session = Depends(get_session)):
    result = create_purchase(session, purchase)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[PurchaseRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_purchases(session: Session = Depends(get_session)):
    return get_all_purchases(session)

@router.get("/recent", response_model=list[PurchaseRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_recent_purchases(session: Session = Depends(get_session)):
    return get_recent_purchases(session)

@router.get("/{purchase_id}", response_model=PurchaseRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_purchase(purchase_id: int, session: Session = Depends(get_session)):
    return get_purchase(session, purchase_id)

@router.put("/{purchase_id}", response_model=PurchaseRead)
async def update_purchase_route(purchase_id: int, purchase: PurchaseUpdate, session: Session = Depends(get_session)):
    result = update_purchase(session, purchase_id, purchase)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{purchase_id}")
async def delete_purchase_route(purchase_id: int, session: Session = Depends(get_session)):
    result = delete_purchase(session, purchase_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result