from fastapi import HTTPException

from sqlmodel import Session, select
from sqlalchemy import exists, or_
from app.models.product import Product
from app.schemas.product.product import ProductCreate, ProductUpdate
from datetime import datetime, timezone
from sqlalchemy.orm import selectinload
 
from app.models.purchase_item import PurchaseItem
from app.models.sale_items import SaleItems
from app.models.stock_adjustment import StockAdjustment
from app.models.warehouse_stock import WarehouseStock
from app.models.warehouse import Warehouse
from app.models.product_transfer_item import ProductTransferItem
from app.models.purchase_request_items import PurchaseRequestItems

def _ensure_warehouse_exists(session: Session, warehouse_id: int):
    if session.get(Warehouse, warehouse_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Warehouse not found."
        )


def _sync_product_warehouse(session: Session, product_id: int, warehouse_id: int):
    """Keep the product's warehouse stock row in sync with the product form."""
    _ensure_warehouse_exists(session, warehouse_id)

    stock = session.exec(
        select(WarehouseStock).where(WarehouseStock.product_id == product_id)
    ).first()

    if stock is None:
        session.add(
            WarehouseStock(
                product_id=product_id,
                warehouse_id=warehouse_id,
                qty=0,
            )
        )
        return

    if stock.warehouse_id == warehouse_id:
        return

    already_in_warehouse = session.exec(
        select(WarehouseStock).where(
            WarehouseStock.product_id == product_id,
            WarehouseStock.warehouse_id == warehouse_id,
        )
    ).first()
    if already_in_warehouse:
        return

    stock.warehouse_id = warehouse_id
    session.add(stock)


def create_product(session: Session, product: ProductCreate):
    if product.warehouse_id is not None:
        _ensure_warehouse_exists(session, product.warehouse_id)

    db_product = Product.model_validate(product)
    session.add(db_product)
    session.flush()

    if product.warehouse_id is not None:
        session.add(
            WarehouseStock(
                product_id=db_product.id,
                warehouse_id=product.warehouse_id,
                qty=0,
            )
        )

    session.commit()
    session.refresh(db_product)
    return db_product

def get_all_product(session: Session):
    statement = (
        select(Product)
        .options(
            selectinload(Product.category),
            selectinload(Product.unit),
            selectinload(Product.currency),
            selectinload(Product.warehouse_stock).selectinload(WarehouseStock.warehouse),
        )
    )
    return session.exec(statement).all()

def get_product(session: Session, product_id: int):
    statement = (
        select(Product)
        .where(Product.id == product_id)
        .options(
            selectinload(Product.category),
            selectinload(Product.unit),
            selectinload(Product.currency),
            selectinload(Product.warehouse_stock).selectinload(WarehouseStock.warehouse),
        )
    )
    return session.exec(statement).first()

def update_product(session: Session, product_id: int, product: ProductUpdate):
    db_product = session.get(Product, product_id)
    if db_product:
        if product.category_id is not None:
            db_product.category_id = product.category_id
        if product.name is not None:
            db_product.name = product.name
        if product.barcode is not None:
            db_product.barcode = product.barcode
        if product.photo is not None:
            db_product.photo = product.photo
        if product.cost_price is not None:
            db_product.cost_price = product.cost_price
        if product.sale_price is not None:
            db_product.sale_price = product.sale_price
        if product.qty is not None:
            db_product.qty = product.qty
        if product.allow_insert_qty is not None:
            db_product.allow_insert_qty = product.allow_insert_qty
        if product.unit_id is not None:
            db_product.unit_id = product.unit_id
        if product.currency_id is not None:
            db_product.currency_id = product.currency_id
        if product.unit_id is not None:
            db_product.unit_id = product.unit_id
        if product.description is not None:
            db_product.description = product.description

        if product.warehouse_id is not None:
            _sync_product_warehouse(session, product_id, product.warehouse_id)

        updated_at = product.updated_at
        if updated_at is not None and updated_at.tzinfo is None:
            updated_at = updated_at.replace(tzinfo=timezone.utc)
        elif updated_at is not None:
            updated_at = updated_at.astimezone(timezone.utc)

        db_product.updated_at = updated_at or datetime.now(timezone.utc)
        session.add(db_product)
        session.commit()
        session.refresh(db_product)
    return db_product

# check if product is used
def is_product_used(session: Session, product_id: int) -> bool:
    statement = select(
        or_(
            exists().where(PurchaseItem.product_id == product_id),
            exists().where(SaleItems.product_id == product_id),
            exists().where(StockAdjustment.product_id == product_id),
            exists().where(WarehouseStock.product_id == product_id),
            exists().where(ProductTransferItem.product_id == product_id),
            exists().where(PurchaseRequestItems.product_id == product_id),
        )
    )
    return bool(session.exec(statement).first())

def delete_product(session: Session, product_id: int):

    if not session.get(Product, product_id):
        raise HTTPException(
            status_code=404,
            detail=" Product not found."
        )
    
    product = session.get(Product, product_id)

    if is_product_used(session, product_id):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete product '{product.name}' because it is being used."
        )

    # delete product
    if product:
        session.delete(product)
        session.commit()
    return {
            "message": "Product deleted successfully",
            "product": product
        }