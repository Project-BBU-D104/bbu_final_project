from fastapi import APIRouter, Depends, HTTPException
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.sale.sale import SaleCreate,SaleRead,SaleUpdate
from app.crud.sale.sale import  create_sale, get_all_sales, get_sale, update_sale, delete_sale

router = APIRouter(prefix="/sale", tags=["sale"])

CACHE_NS = "sale"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=SaleRead)
async def create_new_sale(payment: SaleCreate, session: Session = Depends(get_session)):
    result = create_sale(session, payment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[SaleRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_sales(session: Session = Depends(get_session)):
    return get_all_sales(session)

@router.get("/{sale_id}", response_model=SaleRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_sale(sale_id: int, session: Session = Depends(get_session)):
    sale = get_sale(session, sale_id)
    if sale is None:
        raise HTTPException(status_code=404, detail="Sale not found")
    return sale

@router.put("/{sale_id}", response_model=SaleRead)
def update_sale_route(sale_id: int, sale: SaleUpdate, session: Session = Depends(get_session)):
    updated_sale = update_sale(session, sale_id, sale)
    if updated_sale is None:
        raise HTTPException(status_code=404, detail="Sale not found")
    return updated_sale

@router.delete("/{sale_id}")
async def delete_sale_route(sale_id: int, session: Session = Depends(get_session)):
    deleted_sale = delete_sale(session, sale_id)
    if deleted_sale is None:
        raise HTTPException(status_code=404, detail="Sale not found")

    await FastAPICache.clear(namespace=CACHE_NS)
    return deleted_sale