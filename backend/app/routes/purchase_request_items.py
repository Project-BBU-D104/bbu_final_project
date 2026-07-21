from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.purchase_request_items import PurchaseRequestItemCreate, PurchaseRequestItemRead, PurchaseRequestItemUpdate
from app.crud.purchase_request_items import  create_purchase_request_items, get_all_purchase_request_items, get_purchase_request_items, update_purchase_request_items, delete_purchase_request_items

router = APIRouter(prefix="/purchase_request_items", tags=["purchase_request_items"])

@router.post("/", response_model=PurchaseRequestItemRead)
def create_new_purchase_request_items(purchase_request_items:PurchaseRequestItemCreate, session: Session = Depends(get_session)):
    return create_purchase_request_items(session, purchase_request_items)

@router.get("/", response_model=list[PurchaseRequestItemRead])
def read_all_purchase_request_items(session: Session = Depends(get_session)):
    return get_all_purchase_request_items(session)

@router.get("/{purchase_request_items_id}", response_model=PurchaseRequestItemRead)
def read_purchase_request_items(purchase_request_items_id: int, session: Session = Depends(get_session)):
    return get_purchase_request_items(session, purchase_request_items_id)

@router.put("/{purchase_request_items_id}", response_model=PurchaseRequestItemRead)
def update_purchase_request_items_route(purchase_request_items_id: int, purchase_request_items: PurchaseRequestItemUpdate, session: Session = Depends(get_session)):
    return update_purchase_request_items(session, purchase_request_items_id, purchase_request_items)

@router.delete("/{purchase_request_items_id}")
def delete_purchase_request_items_route(purchase_request_items_id: int, session: Session = Depends(get_session)):
    return delete_purchase_request_items(session, purchase_request_items_id)