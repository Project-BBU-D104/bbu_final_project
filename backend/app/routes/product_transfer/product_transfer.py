from fastapi import APIRouter, Depends, HTTPException
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.product_transfer.product_transfer import ProductTransferCreate,ProductTransferRead,ProductTransferUpdate
from app.crud.product_transfer.product_transfer import  create_product_transfer, get_all_product_transfers, get_product_transfers, update_product_transfer, delete_product_transfer

router = APIRouter(prefix="/product_transfer", tags=["product_transfer"])
CACHE_NS = "product_transfer"
CACHE_TTL = 60 

@router.post("/", response_model=ProductTransferRead)
async def create_new_product_transfer(product_transfer: ProductTransferCreate, session: Session = Depends(get_session)):
    result = create_product_transfer(session, product_transfer)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[ProductTransferRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS,)
async def read_product_transfers(session: Session = Depends(get_session)):
    return get_all_product_transfers(session)

@router.get("/{product_transfer_id}", response_model=ProductTransferRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_stock_adjustment(product_transfer_id: int, session: Session = Depends(get_session)):
    transfer = get_product_transfers(session, product_transfer_id)
    if transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")
    return transfer

@router.put("/{product_transfer_id}", response_model=ProductTransferRead)
async def update_product_transfer_route(
    product_transfer_id: int,
    product_transfer: ProductTransferUpdate,
    session: Session = Depends(get_session)
):
    transfer = update_product_transfer(
        session,
        product_transfer_id,
        product_transfer
    )
    if transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")

    await FastAPICache.clear(namespace=CACHE_NS)
    return transfer

@router.delete("/{product_transfer_id}")
async def delete_product_transfer_route(product_transfer_id: int, session: Session = Depends(get_session)):
    transfer = delete_product_transfer(session, product_transfer_id)
    if transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")
    await FastAPICache.clear(namespace=CACHE_NS)
    return {"message": "Stock transfer deleted successfully."}