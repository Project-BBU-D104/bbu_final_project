from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.warehouse.warehouse import WarehouseCreate, WarehouseRead, WarehouseUpdate
from app.crud.warehouse.warehouse import  create_warehouse, get_all_warehouse, get_warehouse, update_warehouse, delete_warehouse

router = APIRouter(prefix="/warehouse", tags=["warehouse"])

CACHE_NS = "warehouse"
CACHE_TTL = 60

@router.post("/", response_model=WarehouseRead)
async def create_new_warehouse(warehouse: WarehouseCreate, session: Session = Depends(get_session)):
    result = create_warehouse(session, warehouse)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[WarehouseRead])
@cache(namespace=CACHE_NS, expire=CACHE_TTL)
async def read_all_warehouse(session: Session = Depends(get_session)):
    return get_all_warehouse(session)

@router.get("/{warehouse_id}", response_model=WarehouseRead)
@cache(namespace=CACHE_NS, expire=CACHE_TTL)
async def read_warehouse(warehouse_id: int, session: Session = Depends(get_session)):
    return get_warehouse(session, warehouse_id)

@router.put("/{warehouse_id}", response_model=WarehouseRead)
async def update_warehouse_route(warehouse_id: int, warehouse: WarehouseUpdate, session: Session = Depends(get_session)):
    result = update_warehouse(session, warehouse_id, warehouse)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{warehouse_id}")
async def delete_warehouse_route(warehouse_id: int, session: Session = Depends(get_session)):
    result = delete_warehouse(session, warehouse_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result