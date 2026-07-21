from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_request_items import PurchaseRequestItems
from app.schemas.purchase_request_items import PurchaseRequestItemCreate, PurchaseRequestItemUpdate
from datetime import datetime

def create_purchase_request_items(session: Session, purchase_request_item: PurchaseRequestItemCreate):
    db_purchase_request_item = PurchaseRequestItems.from_orm(purchase_request_item)
    session.add(db_purchase_request_item)
    session.commit()
    session.refresh(db_purchase_request_item)
 
    return db_purchase_request_item

def get_all_purchase_request_items(session: Session):
    return session.exec(select(PurchaseRequestItems)).all()

def get_purchase_request_items(session: Session, purchase_request_item_id: int):
    return session.get(PurchaseRequestItems, purchase_request_item_id)

def update_purchase_request_items(session: Session, purchase_request_item_id: int, purchase_request_item: PurchaseRequestItemUpdate):
    if not session.get(PurchaseRequestItems, purchase_request_item_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Request Item not found."
        )
    
    db_purchase_request_item = session.get(PurchaseRequestItems, purchase_request_item_id)
    if db_purchase_request_item:
        if purchase_request_item.stock_request_id is not None:
            db_purchase_request_item.stock_request_id = purchase_request_item.stock_request_id
        if purchase_request_item.product_id is not None:
            db_purchase_request_item.product_id = purchase_request_item.product_id
        if purchase_request_item.unit is not None:
            db_purchase_request_item.unit = purchase_request_item.unit
        if purchase_request_item.qty is not None:
            db_purchase_request_item.qty = purchase_request_item.qty 

        db_purchase_request_item.updated_at = purchase_request_item.updated_at or datetime.utcnow()
        session.add(db_purchase_request_item)
        session.commit()
        session.refresh(db_purchase_request_item)
    return db_purchase_request_item

def delete_purchase_request_items(session: Session, purchase_request_item_id: int):
    if not session.get(PurchaseRequestItems, purchase_request_item_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Request Item not found."
        )
    
    purchase_request_item = session.get(PurchaseRequestItems, purchase_request_item_id)

    if purchase_request_item:
        session.delete(purchase_request_item)
        session.commit()
    return {
        "message": "Purchase Request Item deleted successfully",
        "purchase_request": purchase_request_item
    }