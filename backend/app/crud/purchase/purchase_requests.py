from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_requests import PurchaseRequest
from app.schemas.purchase.purchase_requests import PurchaseRequestCreate, PurchaseRequestUpdate
from datetime import datetime

def create_purchase_request(session: Session, purchase_request: PurchaseRequestCreate):
    db_purchase_request = PurchaseRequest.from_orm(purchase_request)
    session.add(db_purchase_request)
    session.commit()
    session.refresh(db_purchase_request)
 
    return db_purchase_request

def get_all_purchase_request(session: Session):
    return session.exec(select(PurchaseRequest)).all()

def get_purchase_request(session: Session, purchase_request_id: int):
    return session.get(PurchaseRequest, purchase_request_id)

def update_purchase_request(session: Session, purchase_request_id: int, purchase_request: PurchaseRequestUpdate):
    if not session.get(PurchaseRequest, purchase_request_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Request not found."
        )
    
    db_purchase_request = session.get(PurchaseRequest, purchase_request_id)
    if db_purchase_request:
        if purchase_request.request_no is not None:
            db_purchase_request.request_no = purchase_request.request_no
        if purchase_request.request_type is not None:
            db_purchase_request.request_type = purchase_request.request_type
        if purchase_request.warehouse_id is not None:
            db_purchase_request.warehouse_id = purchase_request.warehouse_id
        if purchase_request.requested_by is not None:
            db_purchase_request.requested_by = purchase_request.requested_by
        if purchase_request.approved_by is not None:
            db_purchase_request.approved_by = purchase_request.approved_by
        if purchase_request.status is not None:
            db_purchase_request.status = purchase_request.status
        if purchase_request.reason is not None:
            db_purchase_request.reason = purchase_request.reason
        if purchase_request.request_date is not None:
            db_purchase_request.request_date = purchase_request.request_date
        if purchase_request.approved_date is not None:
            db_purchase_request.approved_date = purchase_request.approved_date

        db_purchase_request.updated_at = purchase_request.updated_at or datetime.utcnow()
        session.add(db_purchase_request)
        session.commit()
        session.refresh(db_purchase_request)
    return db_purchase_request

def delete_purchase_request(session: Session, purchase_request_id: int):
    if not session.get(PurchaseRequest, purchase_request_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Request not found."
        )
    
    purchase_request = session.get(PurchaseRequest, purchase_request_id)

    if purchase_request:
        session.delete(purchase_request)
        session.commit()
    return {
        "message": "Purchase Request deleted successfully",
        "purchase_request": purchase_request
    }