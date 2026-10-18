from fastapi import HTTPException
from sqlalchemy.orm import selectinload
from sqlmodel import Session, select
from app.models.product_transfer import ProductTransfer
from app.models.product_transfer_item import ProductTransferItem
from app.schemas.product_transfer.product_transfer_item import (
    ProductTransferItemCreate,
    ProductTransferItemUpdate,
)
from app.crud.product_transfer.product_transfer import _move_stock, _reverse_stock


def _item_statement():
    return select(ProductTransferItem).options(
        selectinload(ProductTransferItem.product),
    )

def create_product_transfer_item(session: Session, product_transfer_item: ProductTransferItemCreate):
    transfer = session.get(ProductTransfer, product_transfer_item.product_transfer_id)
    if transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")
    duplicate = session.exec(
        select(ProductTransferItem).where(
            ProductTransferItem.product_transfer_id == transfer.id,
            ProductTransferItem.product_id == product_transfer_item.product_id,
        )
    ).first()
    if duplicate is not None:
        raise HTTPException(
            status_code=400,
            detail="This product is already included in the transfer.",
        )

    try:
        _move_stock(
            session,
            transfer.from_warehouse_id,
            transfer.to_warehouse_id,
            product_transfer_item.product_id,
            product_transfer_item.qty,
        )
        db_item = ProductTransferItem(**product_transfer_item.model_dump())
        session.add(db_item)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return get_product_transfer_item(session, db_item.id)

def get_all_product_transfer_item(session: Session):
    return session.exec(_item_statement().order_by(ProductTransferItem.id.desc())).all()

def get_product_transfer_item(session: Session, product_transfer_item_id: int):
    statement = _item_statement().where(ProductTransferItem.id == product_transfer_item_id)
    return session.exec(statement).first()

def update_product_transfer_item(session: Session, product_transfer_item_id: int, product_transfer_item: ProductTransferItemUpdate):
    db_item = session.get(ProductTransferItem, product_transfer_item_id)
    if db_item is None:
        return None

    old_transfer = session.get(ProductTransfer, db_item.product_transfer_id)
    updates = product_transfer_item.model_dump(exclude_unset=True)
    new_transfer_id = updates.get("product_transfer_id", db_item.product_transfer_id)
    new_product_id = updates.get("product_id", db_item.product_id)
    new_qty = updates.get("qty", db_item.qty)
    new_transfer = session.get(ProductTransfer, new_transfer_id)
    if old_transfer is None or new_transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")
    duplicate = session.exec(
        select(ProductTransferItem).where(
            ProductTransferItem.product_transfer_id == new_transfer.id,
            ProductTransferItem.product_id == new_product_id,
            ProductTransferItem.id != product_transfer_item_id,
        )
    ).first()
    if duplicate is not None:
        raise HTTPException(
            status_code=400,
            detail="This product is already included in the transfer.",
        )

    try:
        if (
            old_transfer.id == new_transfer.id
            and db_item.product_id == new_product_id
        ):
            if new_qty > db_item.qty:
                _move_stock(
                    session,
                    new_transfer.from_warehouse_id,
                    new_transfer.to_warehouse_id,
                    new_product_id,
                    new_qty - db_item.qty,
                )
            elif db_item.qty > new_qty:
                _reverse_stock(
                    session,
                    new_transfer.from_warehouse_id,
                    new_transfer.to_warehouse_id,
                    new_product_id,
                    db_item.qty - new_qty,
                )
        else:
            _reverse_stock(
                session,
                old_transfer.from_warehouse_id,
                old_transfer.to_warehouse_id,
                db_item.product_id,
                db_item.qty,
            )
            _move_stock(
                session,
                new_transfer.from_warehouse_id,
                new_transfer.to_warehouse_id,
                new_product_id,
                new_qty,
            )

        db_item.product_transfer_id = new_transfer_id
        db_item.product_id = new_product_id
        db_item.qty = new_qty
        session.add(db_item)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return get_product_transfer_item(session, product_transfer_item_id)

def delete_product_transfer_item(session: Session, product_transfer_item_id: int):
    product_transfer_item = session.get(ProductTransferItem, product_transfer_item_id)
    if product_transfer_item is None:
        return None

    transfer = session.get(ProductTransfer, product_transfer_item.product_transfer_id)
    if transfer is None:
        raise HTTPException(status_code=404, detail="Stock transfer not found.")

    try:
        _reverse_stock(
            session,
            transfer.from_warehouse_id,
            transfer.to_warehouse_id,
            product_transfer_item.product_id,
            product_transfer_item.qty,
        )
        session.delete(product_transfer_item)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return product_transfer_item