from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.purchase.purchase import PurchaseCreate,PurchaseRead,PurchaseUpdate,PurchaseSimple
from app.crud.purchase.purchase import  create_purchase, get_all_purchases,get_recent_purchases, get_purchase, update_purchase, delete_purchase

router = APIRouter(prefix="/purchase", tags=["purchase"])

@router.post("/", response_model=PurchaseRead)
def create_new_purchase(purchase: PurchaseCreate, session: Session = Depends(get_session)):
    return create_purchase(session, purchase)

@router.get("/", response_model=list[PurchaseRead])
def read_purchases(session: Session = Depends(get_session)):
    return get_all_purchases(session)

@router.get("/recent", response_model=list[PurchaseRead])
def read_recent_purchases(session: Session = Depends(get_session)):
    return get_recent_purchases(session)

@router.get("/{purchase_id}", response_model=PurchaseRead)
def read_purchase(purchase_id: int, session: Session = Depends(get_session)):
    return get_purchase(session, purchase_id)

@router.put("/{purchase_id}", response_model=PurchaseRead)
def update_purchase_route(purchase_id: int, purchase: PurchaseUpdate, session: Session = Depends(get_session)):
    return update_purchase(session, purchase_id, purchase)

@router.delete("/{purchase_id}")
def delete_purchase_route(purchase_id: int, session: Session = Depends(get_session)):
    return delete_purchase(session, purchase_id)