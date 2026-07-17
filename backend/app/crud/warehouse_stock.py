from sqlmodel import Session, select
from app.models.warehouse_stock import WarehouseStock
from app.schemas.warehouse_stock import WarehouseStockCreate, WarehouseStockUpdate
from datetime import datetime

from fastapi import HTTPException

def check_product_in_warehouse(
    session: Session,
    warehouse_id: int,
    product_id: int,
):
    stock = session.exec(
        select(WarehouseStock).where(
            WarehouseStock.warehouse_id == warehouse_id,
            WarehouseStock.product_id == product_id,
        )
    ).first()

    if stock is None:
        raise HTTPException(
            status_code=400,
            detail="Product is not assigned to this warehouse."
        )

    return stock


def create_warehouse_stock(
    session: Session,
    warehouse_stock: WarehouseStockCreate
):
    stocks = []

    for item in warehouse_stock.items:
        # Check duplicate product in same warehouse
        existing_stock = session.exec(
            select(WarehouseStock).where(
                WarehouseStock.warehouse_id == warehouse_stock.warehouse_id,
                WarehouseStock.product_id == item.product_id
            )
        ).first()

        if existing_stock:
            raise HTTPException(
                status_code=400,
                detail=f"Product ID {item.product_id} already exists in this warehouse"
            )
        
        stock = WarehouseStock(
            warehouse_id=warehouse_stock.warehouse_id,
            product_id=item.product_id,
            qty=item.qty
        )
        session.add(stock)
        stocks.append(stock)

    session.commit()
    
    for stock in stocks:
        session.refresh(stock)

    return stocks

def get_all_warehouse_stock(session: Session):
    return session.exec(select(WarehouseStock)).all()

def get_warehouse_stock(session: Session, warehouse_stock_id: int):
    return session.get(WarehouseStock, warehouse_stock_id)

def update_warehouse_stock(
    session: Session,
    warehouse_stock_id: int,
    warehouse_stock: WarehouseStockUpdate,
):
    db_stock = session.get(WarehouseStock, warehouse_stock_id)

    if not db_stock:
        return None

    db_stock.warehouse_id = warehouse_stock.warehouse_id

    item = warehouse_stock.items[0]

    db_stock.product_id = item.product_id
    db_stock.qty = item.qty

    session.add(db_stock)
    session.commit()
    session.refresh(db_stock)

    return db_stock

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