from sqlmodel import Session, select
from app.models.stock_adjustment import StockAdjustment
from app.schemas.stock_adjustment import StockAdjustmentCreate, StockAdjustmentUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_stock_adjustment(session: Session, stock_adjustment: StockAdjustmentCreate):
    db_stock_adjustment = StockAdjustment.model_validate(stock_adjustment)
    session.add(db_stock_adjustment)
    session.commit()
    session.refresh(db_stock_adjustment)
    return db_stock_adjustment

def get_all_stock_adjustments(session: Session):
    statement = (
        select(StockAdjustment)
        .options(
            selectinload(StockAdjustment.product),
            selectinload(StockAdjustment.warehouse),
            selectinload(StockAdjustment.user),
        )
    )
    return session.exec(statement).all()

def get_stock_adjustments(session: Session, stock_adjustment_id: int):
    statement = (
        select(StockAdjustment)
        .where(StockAdjustment.id == stock_adjustment_id)
        .options(
            selectinload(StockAdjustment.product),
            selectinload(StockAdjustment.warehouse),
            selectinload(StockAdjustment.user),
        )
    )
    return session.exec(statement).first()

def update_stock_adjustment(session: Session, stock_adjustment_id: int, stock_adjustment: StockAdjustmentUpdate):
    db_stock_adjustment = session.get(StockAdjustment, stock_adjustment_id)
    if db_stock_adjustment:
        if stock_adjustment.product_id is not None:
            db_stock_adjustment.product_id = stock_adjustment.product_id
        if stock_adjustment.warehouse_id is not None:
            db_stock_adjustment.warehouse_id = stock_adjustment.warehouse_id
        if stock_adjustment.user_id is not None:
            db_stock_adjustment.user_id = stock_adjustment.warehouse_id
        if stock_adjustment.adjustment_type is not None:
            db_stock_adjustment.adjustment_type = stock_adjustment.adjustment_type
        if stock_adjustment.qty is not None:
            db_stock_adjustment.qty = stock_adjustment.qty
        if stock_adjustment.previous_qty is not None:
            db_stock_adjustment.previous_qty = stock_adjustment.previous_qty
        if stock_adjustment.new_qty is not None:
            db_stock_adjustment.new_qty = stock_adjustment.new_qty
        if stock_adjustment.reason is not None:
            db_stock_adjustment.reason = stock_adjustment.reason
        if stock_adjustment.reference_no is not None:
            db_stock_adjustment.reference_no = stock_adjustment.reference_no

        db_stock_adjustment.updated_at = stock_adjustment.updated_at or datetime.utcnow()
        session.add(db_stock_adjustment)
        session.commit()
        session.refresh(db_stock_adjustment)
    return db_stock_adjustment

def delete_stock_adjustment(session: Session, stock_adjustment_id: int):
    stock_adjustment = session.get(StockAdjustment, stock_adjustment_id)
    if stock_adjustment:
        session.delete(stock_adjustment)
        session.commit()
    return stock_adjustment