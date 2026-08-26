from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase_item import PurchaseItemCreate,PurchaseItemRead
from app.crud.purchase.purchase_item import  create_purchase_item, get_all_purchase_items, delete_purchase_item

router = APIRouter(prefix="/purchase_item", tags=["purchase_item"])

@router.post("/", response_model=PurchaseItemRead)
def create_new_purchase_item(purchase_item: PurchaseItemCreate, session: Session = Depends(get_session)):
    return create_purchase_item(session, purchase_item)

@router.get("/", response_model=list[PurchaseItemRead])
def read_purchase_items(session: Session = Depends(get_session)):
    return get_all_purchase_items(session)


@router.delete("/{purchase_item_id}")
def delete_purchase_item_route(purchase_item_id: int, session: Session = Depends(get_session)):
    return delete_purchase_item(session, purchase_item_id)