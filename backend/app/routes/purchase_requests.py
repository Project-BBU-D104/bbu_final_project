from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.purchase_requests import PurchaseRequestCreate, PurchaseRequestRead, PurchaseRequestUpdate
from app.crud.purchase_requests import  create_purchase_request, get_all_purchase_request, get_purchase_request, update_purchase_request, delete_purchase_request

router = APIRouter(prefix="/purchase_request", tags=["purchase_request"])

@router.post("/", response_model=PurchaseRequestRead)
def create_new_purchase_request(purchase_request: PurchaseRequestCreate, session: Session = Depends(get_session)):
    return create_purchase_request(session, purchase_request)

@router.get("/", response_model=list[PurchaseRequestRead])
def read_all_purchase_request(session: Session = Depends(get_session)):
    return get_all_purchase_request(session)

@router.get("/{purchase_request_id}", response_model=PurchaseRequestRead)
def read_purchase_request(purchase_request_id: int, session: Session = Depends(get_session)):
    return get_purchase_request(session, purchase_request_id)

@router.put("/{purchase_request_id}", response_model=PurchaseRequestRead)
def update_purchase_request_route(purchase_request_id: int, purchase_request: PurchaseRequestUpdate, session: Session = Depends(get_session)):
    return update_purchase_request(session, purchase_request_id, purchase_request)

@router.delete("/{purchase_request_id}")
def delete_purchase_request_route(purchase_request_id: int, session: Session = Depends(get_session)):
    return delete_purchase_request(session, purchase_request_id)