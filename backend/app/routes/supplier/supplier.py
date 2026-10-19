from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.supplier.supplier import SupplierCreate, SupplierRead, SupplierUpdate
from app.crud.supplier.supplier import  create_supplier, get_all_supplier, get_supplier, update_supplier, delete_supplier

router = APIRouter(prefix="/supplier", tags=["supplier"])

CACHE_NS = "supplier"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=SupplierRead)
async def create_new_supplier(supplier: SupplierCreate, session: Session = Depends(get_session)):
    result = create_supplier(session, supplier)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[SupplierRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_supplier(session: Session = Depends(get_session)):
    return get_all_supplier(session)

@router.get("/{supplier_id}", response_model=SupplierRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_supplier(supplier_id: int, session: Session = Depends(get_session)):
    return get_supplier(session, supplier_id)

@router.put("/{supplier_id}", response_model=SupplierRead)
async def update_supplier_route(supplier_id: int, supplier: SupplierUpdate, session: Session = Depends(get_session)):
    result = update_supplier(session, supplier_id, supplier)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{supplier_id}")
async def delete_supplier_route(supplier_id: int, session: Session = Depends(get_session)):
    result = delete_supplier(session, supplier_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result