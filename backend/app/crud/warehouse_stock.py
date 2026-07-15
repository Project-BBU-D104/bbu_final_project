from sqlmodel import Session, select
from app.models.warehouse_stock import WarehouseStock
from app.schemas.warehouse_stock import WarehouseStockCreate, WarehouseStockUpdate
from datetime import datetime

def create_warehouse_stock(session: Session, warehouse_stock: WarehouseStockCreate):
    db_warehouse_stock = WarehouseStock.model_validate(warehouse_stock)
    session.add(db_warehouse_stock)
    session.commit()
    session.refresh(db_warehouse_stock)
    return db_warehouse_stock

def get_all_warehouse_stock(session: Session):
    return session.exec(select(WarehouseStock)).all()

def get_warehouse_stock(session: Session, warehouse_stock_id: int):
    return session.get(WarehouseStock, warehouse_stock_id)

def update_warehouse_stock(session: Session, warehouse_stock_id: int, warehouse_stock: WarehouseStockUpdate):
    db_warehouse_stock = session.get(WarehouseStock, warehouse_stock_id)
    if db_warehouse_stock:
        if warehouse_stock.product_id is not None:
            db_warehouse_stock.product_id = warehouse_stock.product_id
        if warehouse_stock.warehouse_id is not None:
            db_warehouse_stock.warehouse_id = warehouse_stock.warehouse_id
        if warehouse_stock.qty is not None:
            db_warehouse_stock.qty = warehouse_stock.qty
         
        session.add(db_warehouse_stock)
        session.commit()
        session.refresh(db_warehouse_stock)
    return db_warehouse_stock

def delete_warehouse_stock(session: Session, warehouse_stock_id: int):
    warehouse_stock = session.get(WarehouseStock, warehouse_stock_id)
    if warehouse_stock:
        session.delete(warehouse_stock)
        session.commit()
    return warehouse_stock


# -----------------------------------------
# Inventory Helper Functions
# -----------------------------------------

def increase_stock(
    session: Session,
    product_id: int,
    warehouse_id: int,
    qty: int,
):
    """
    Increase warehouse stock after purchase.
    """

    stock = session.exec(
        select(WarehouseStock).where(
            WarehouseStock.product_id == product_id,
            WarehouseStock.warehouse_id == warehouse_id,
        )
    ).first()

    if stock:
        stock.qty += qty
    else:
        stock = WarehouseStock(
            product_id=product_id,
            warehouse_id=warehouse_id,
            qty=qty,
        )
        session.add(stock)

    return stock


def decrease_stock(
    session: Session,
    product_id: int,
    warehouse_id: int,
    qty: int,
):
    """
    Decrease warehouse stock after sale.
    """

    stock = session.exec(
        select(WarehouseStock).where(
            WarehouseStock.product_id == product_id,
            WarehouseStock.warehouse_id == warehouse_id,
        )
    ).first()

    if stock is None:
        raise ValueError("Stock not found.")

    if stock.qty < qty:
        raise ValueError("Insufficient stock.")

    stock.qty -= qty

    return stock