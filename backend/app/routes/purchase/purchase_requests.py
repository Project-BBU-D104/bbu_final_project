from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase_requests import PurchaseRequestCreate, PurchaseRequestRead, PurchaseRequestUpdate
from app.crud.purchase.purchase_requests import  create_purchase_request, get_all_purchase_request, get_purchase_request, update_purchase_request, delete_purchase_request

router = APIRouter(prefix="/purchase_request", tags=["purchase_request"])

CACHE_NS = "purchase_request"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=PurchaseRequestRead)
async def create_new_purchase_request(purchase_request: PurchaseRequestCreate, session: Session = Depends(get_session)):
    result = create_purchase_request(session, purchase_request)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[PurchaseRequestRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_purchase_request(session: Session = Depends(get_session)):
    return get_all_purchase_request(session)

@router.get("/{purchase_request_id}", response_model=PurchaseRequestRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_purchase_request(purchase_request_id: int, session: Session = Depends(get_session)):
    return get_purchase_request(session, purchase_request_id)

@router.put("/{purchase_request_id}", response_model=PurchaseRequestRead)
async def update_purchase_request_route(purchase_request_id: int, purchase_request: PurchaseRequestUpdate, session: Session = Depends(get_session)):
    result = update_purchase_request(session, purchase_request_id, purchase_request)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{purchase_request_id}")
async def delete_purchase_request_route(purchase_request_id: int, session: Session = Depends(get_session)):
    result = delete_purchase_request(session, purchase_request_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result