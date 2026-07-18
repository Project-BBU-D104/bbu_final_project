from sqlmodel import Session, select
from app.models.stock_adjustment import StockAdjustment
from app.schemas.stock_adjustment import StockAdjustmentCreate, StockAdjustmentUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload
from fastapi import HTTPException
from app.crud.warehouse_stock import get_stock_by_product_and_warehouse


def generate_reference_no(session: Session) -> str:
    # Get the latest stock adjustment
    last_stock_adjustment = session.exec(
        select(StockAdjustment).order_by(StockAdjustment.id.desc())
    ).first()

    if last_stock_adjustment is None:
        return "SDJ001"

    # If previous invoice is SDJ001 -> number = 1
    try:
        last_number = int(last_stock_adjustment.reference_no.replace("SDJ", ""))
    except:
        last_number = last_stock_adjustment.id

    return f"SDJ{last_number + 1:04d}"

def create_stock_adjustment(
    session: Session,
    stock_adjustment: StockAdjustmentCreate,
):
    if not stock_adjustment.reference_no:
        stock_adjustment.reference_no = generate_reference_no(session)

    # Get current warehouse stock
    stock = get_stock_by_product_and_warehouse(
        session,
        stock_adjustment.warehouse_id,
        stock_adjustment.product_id,
    )

    previous_qty = stock.qty

    # Calculate new quantity
    if stock_adjustment.adjustment_type == "increase":
        new_qty = previous_qty + stock_adjustment.qty

    elif stock_adjustment.adjustment_type == "decrease":

        if stock_adjustment.qty > previous_qty:
            raise HTTPException(
                status_code=400,
                detail="Insufficient stock."
            )

        new_qty = previous_qty - stock_adjustment.qty

    else:
        raise HTTPException(
            status_code=400,
            detail="Invalid adjustment type."
        )

    # Update warehouse stock
    stock.qty = new_qty

    # Create adjustment history
    db_stock_adjustment = StockAdjustment(
        product_id=stock_adjustment.product_id,
        warehouse_id=stock_adjustment.warehouse_id,
        user_id=stock_adjustment.user_id,
        adjustment_type=stock_adjustment.adjustment_type,
        previous_qty=previous_qty,
        qty=stock_adjustment.qty,
        new_qty=new_qty,
        reason=stock_adjustment.reason,
        reference_no=stock_adjustment.reference_no,
    )

    session.add(db_stock_adjustment)
    session.add(stock)

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

def delete_stock_adjustment(
    session: Session,
    stock_adjustment_id: int,
):
    stock_adjustment = session.get(
        StockAdjustment,
        stock_adjustment_id,
    )

    if stock_adjustment is None:
        return None

    # Get warehouse stock
    stock = get_stock_by_product_and_warehouse(
        session,
        stock_adjustment.warehouse_id,
        stock_adjustment.product_id,
    )

    # Reverse stock movement
    if stock_adjustment.adjustment_type == "increase":
        stock.qty -= stock_adjustment.qty

    elif stock_adjustment.adjustment_type == "decrease":
        stock.qty += stock_adjustment.qty

    # Optional safety check
    if stock.qty < 0:
        raise HTTPException(
            status_code=400,
            detail="Stock cannot be negative."
        )

    session.add(stock)

    session.delete(stock_adjustment)

    session.commit()

    return stock_adjustment