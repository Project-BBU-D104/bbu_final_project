from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.warehouse.warehouse_stock import WarehouseStockCreate, WarehouseStockRead, WarehouseStockUpdate
from app.crud.warehouse.warehouse_stock import  create_warehouse_stock, get_all_warehouse_stock, get_warehouse_stock, update_warehouse_stock, delete_warehouse_stock, get_stock_by_product_and_warehouse
from app.core.cache import clear_stock_caches

router = APIRouter(prefix="/warehouse_stock", tags=["warehouse_stock"])


@router.post("/", response_model=list[WarehouseStockRead])
async def create_new_warehouse_stock(warehouse_stock: WarehouseStockCreate, session: Session = Depends(get_session)):
    result = create_warehouse_stock(session, warehouse_stock)
    await clear_stock_caches()
    return result

@router.get("/", response_model=list[WarehouseStockRead])
def read_all_warehouse_stock(session: Session = Depends(get_session)):
    return get_all_warehouse_stock(session)

@router.get(
    "/warehouse/{warehouse_id}/product/{product_id}",
    response_model=WarehouseStockRead,
)
def get_product_stock(
    warehouse_id: int,
    product_id: int,
    session: Session = Depends(get_session),
):
    return get_stock_by_product_and_warehouse(
        session,
        warehouse_id,
        product_id,
    )

@router.get("/{warehouse_stock_id}", response_model=WarehouseStockRead)
def read_warehouse_stock(warehouse_stock_id: int, session: Session = Depends(get_session)):
    return get_warehouse_stock(session, warehouse_stock_id)

@router.put("/{warehouse_stock_id}", response_model=WarehouseStockRead)
async def update_warehouse_stock_route(warehouse_stock_id: int, warehouse_stock: WarehouseStockUpdate, session: Session = Depends(get_session)):
    result = update_warehouse_stock(session, warehouse_stock_id, warehouse_stock)
    await clear_stock_caches()
    return result

@router.delete("/{warehouse_stock_id}")
async def delete_warehouse_stock_route(warehouse_stock_id: int, session: Session = Depends(get_session)):
    result = delete_warehouse_stock(session, warehouse_stock_id)
    await clear_stock_caches()
    return result