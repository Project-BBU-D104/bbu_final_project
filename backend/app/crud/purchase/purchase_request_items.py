from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_request_items import PurchaseRequestItems
from app.models.purchase_requests import PurchaseRequest
from app.models.product import Product
from app.schemas.purchase.purchase_request_items import PurchaseRequestItemCreate, PurchaseRequestItemUpdate
from datetime import datetime

def _item_response(item: PurchaseRequestItems):
    return {
        "id": item.id,
        "stock_request_id": item.purchase_request_id,
        "product_id": item.product_id,
        "unit": item.unit,
        "qty": item.qty,
        "created_at": item.created_at,
    }

def create_purchase_request_items(session: Session, purchase_request_item: PurchaseRequestItemCreate):
    purchase_request = session.get(PurchaseRequest, purchase_request_item.stock_request_id)
    if not purchase_request:
        raise HTTPException(status_code=404, detail="Purchase Request not found.")
    if not session.get(Product, purchase_request_item.product_id):
        raise HTTPException(status_code=404, detail="Product not found.")

    db_purchase_request_item = PurchaseRequestItems(
        purchase_request_id=purchase_request_item.stock_request_id,
        product_id=purchase_request_item.product_id,
        unit=purchase_request_item.unit,
        qty=purchase_request_item.qty,
    )
    session.add(db_purchase_request_item)
    session.commit()
    session.refresh(db_purchase_request_item)
 
    return _item_response(db_purchase_request_item)

def get_all_purchase_request_items(session: Session):
    items = session.exec(select(PurchaseRequestItems)).all()
    return [_item_response(item) for item in items]

def get_purchase_request_items(session: Session, purchase_request_item_id: int):
    item = session.get(PurchaseRequestItems, purchase_request_item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Purchase Request Item not found.")
    return _item_response(item)

def update_purchase_request_items(session: Session, purchase_request_item_id: int, purchase_request_item: PurchaseRequestItemUpdate):
    db_purchase_request_item = session.get(PurchaseRequestItems, purchase_request_item_id)
    if not db_purchase_request_item:
        raise HTTPException(status_code=404, detail="Purchase Request Item not found.")

    item_data = purchase_request_item.model_dump(exclude_unset=True, exclude_none=True)
    if "stock_request_id" in item_data:
        purchase_request = session.get(PurchaseRequest, item_data["stock_request_id"])
        if not purchase_request:
            raise HTTPException(status_code=404, detail="Purchase Request not found.")
        db_purchase_request_item.purchase_request_id = item_data.pop("stock_request_id")
    if "product_id" in item_data and not session.get(Product, item_data["product_id"]):
        raise HTTPException(status_code=404, detail="Product not found.")

    for field, value in item_data.items():
        setattr(db_purchase_request_item, field, value)

    session.add(db_purchase_request_item)
    session.commit()
    session.refresh(db_purchase_request_item)
    return _item_response(db_purchase_request_item)

def delete_purchase_request_items(session: Session, purchase_request_item_id: int):
    purchase_request_item = session.get(PurchaseRequestItems, purchase_request_item_id)
    if not purchase_request_item:
        raise HTTPException(status_code=404, detail="Purchase Request Item not found.")

    item_response = _item_response(purchase_request_item)
    session.delete(purchase_request_item)
    session.commit()
    return {
        "message": "Purchase Request Item deleted successfully",
        "purchase_request_item": item_response,
    }