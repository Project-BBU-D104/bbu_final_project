from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.stock.stock_adjustment import StockAdjustmentCreate,StockAdjustmentRead,StockAdjustmentUpdate
from app.crud.stock.stock_adjustment import  create_stock_adjustment, get_all_stock_adjustments, get_stock_adjustments, update_stock_adjustment, delete_stock_adjustment

router = APIRouter(prefix="/stock_adjustment", tags=["stock_adjustment"])

@router.post("/", response_model=StockAdjustmentRead)
def create_new_stock_adjustment(stock_adjustment: StockAdjustmentCreate, session: Session = Depends(get_session)):
    return create_stock_adjustment(session, stock_adjustment)

@router.get("/", response_model=list[StockAdjustmentRead])
def read_stock_adjustments(session: Session = Depends(get_session)):
    return get_all_stock_adjustments(session)

@router.get("/{stock_adjustment_id}", response_model=StockAdjustmentRead)
def read_stock_adjustment(stock_adjustment_id: int, session: Session = Depends(get_session)):
    return get_stock_adjustments(session, stock_adjustment_id)

@router.put("/{stock_adjustment_id}", response_model=StockAdjustmentRead)
def updatestock_adjustment_route(stock_adjustment_id: int, stock_adjustment: StockAdjustmentUpdate, session: Session = Depends(get_session)):
    return update_stock_adjustment(session, stock_adjustment_id, stock_adjustment)

@router.delete("/{stock_adjustment_id}")
def delete_stock_adjustment_route(stock_adjustment_id: int, session: Session = Depends(get_session)):
    return delete_stock_adjustment(session, stock_adjustment_id)