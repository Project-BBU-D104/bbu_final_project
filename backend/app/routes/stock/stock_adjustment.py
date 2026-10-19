from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.stock.stock_adjustment import StockAdjustmentCreate,StockAdjustmentRead,StockAdjustmentUpdate
from app.crud.stock.stock_adjustment import  create_stock_adjustment, get_all_stock_adjustments, get_stock_adjustments, update_stock_adjustment, delete_stock_adjustment

router = APIRouter(prefix="/stock_adjustment", tags=["stock_adjustment"])

CACHE_NS = "stock_adjustment"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=StockAdjustmentRead)
async def create_new_stock_adjustment(stock_adjustment: StockAdjustmentCreate, session: Session = Depends(get_session)):
    result = create_stock_adjustment(session, stock_adjustment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[StockAdjustmentRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_stock_adjustments(session: Session = Depends(get_session)):
    return get_all_stock_adjustments(session)

@router.get("/{stock_adjustment_id}", response_model=StockAdjustmentRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_stock_adjustment(stock_adjustment_id: int, session: Session = Depends(get_session)):
    return get_stock_adjustments(session, stock_adjustment_id)

@router.put("/{stock_adjustment_id}", response_model=StockAdjustmentRead)
async def updatestock_adjustment_route(stock_adjustment_id: int, stock_adjustment: StockAdjustmentUpdate, session: Session = Depends(get_session)):
    result = update_stock_adjustment(session, stock_adjustment_id, stock_adjustment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{stock_adjustment_id}")
async def delete_stock_adjustment_route(stock_adjustment_id: int, session: Session = Depends(get_session)):
    result = delete_stock_adjustment(session, stock_adjustment_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result