from sqlmodel import Session, select
from app.crud.warehouse_stock import increase_stock
from app.models.purchase_item import PurchaseItem
from app.schemas.purchase_item import PurchaseItemCreate
from datetime import datetime
from sqlalchemy.orm import selectinload
from app.models.purchase import Purchase
from app.models.purchase_item import PurchaseItem

def create_purchase_item(session: Session, purchase_item: PurchaseItemCreate):
    
    db_purchase_item = PurchaseItem.model_validate(purchase_item)

    session.add(db_purchase_item)
    session.flush()

    purchase = session.get(Purchase, purchase_item.purchase_id)

    increase_stock(
        session=session,
        product_id=purchase_item.product_id,
        warehouse_id=purchase.warehouse_id,
        qty=purchase_item.qty,
    )

    session.commit()
    session.refresh(db_purchase_item)

    return db_purchase_item

def get_all_purchase_items(session: Session):
    return session.exec(select(PurchaseItem)).all()

def delete_purchase_item(session: Session, purchase_item_id: int):
    purchase_item = session.get(PurchaseItem, purchase_item_id)
    if purchase_item:
        session.delete(purchase_item)
        session.commit()
    return purchase_item

