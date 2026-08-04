from sqlmodel import Session, select
from app.models.product_transfer_item import ProductTransferItem
from app.schemas.product_transfer_item import ProductTransferItemCreate, ProductTransferItemUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_product_transfer_item(session: Session, product_transfer_item: ProductTransferItemCreate):

    db_product_transfer_item = ProductTransferItem(**product_transfer_item.model_dump())

    session.add(db_product_transfer_item)
    session.commit()
    session.refresh(db_product_transfer_item)
    return db_product_transfer_item

def get_all_product_transfer_item(session: Session):
    statement = (
        select(ProductTransferItem)
        .options(
            selectinload(ProductTransferItem.product),
        )
    )
    return session.exec(statement).all()

def get_product_transfer_item(session: Session, product_transfer_item_id: int):
    statement = (
        select(ProductTransferItem)
        .where(ProductTransferItem.id == product_transfer_item_id)
        .options(
            selectinload(ProductTransferItem.product)
        )
    )
    return session.exec(statement).first()

def update_product_transfer_item(session: Session, product_transfer_item_id: int, product_transfer_item: ProductTransferItemUpdate):
    db_product_transfer_item = session.get(ProductTransferItem, product_transfer_item_id)
    if db_product_transfer_item:
        if product_transfer_item.product_transfer_id is not None:
            db_product_transfer_item.product_transfer_id = product_transfer_item.product_transfer_id
        if product_transfer_item.product_id is not None:
            db_product_transfer_item.product_id = product_transfer_item.product_id
        if product_transfer_item.qty is not None:
            db_product_transfer_item.qty = product_transfer_item.qty

        session.add(db_product_transfer_item)
        session.commit()
        session.refresh(db_product_transfer_item)
    return db_product_transfer_item

def delete_product_transfer_item(session: Session, product_transfer_item_id: int):
    product_transfer_item = session.get(ProductTransferItem, product_transfer_item_id)
    if product_transfer_item:
        session.delete(product_transfer_item)
        session.commit()
    return product_transfer_item