from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.product_transfer_item import ProductTransferItemCreate,ProductTransferItemRead,ProductTransferItemUpdate
from app.crud.product_transfer_item import  create_product_transfer_item, get_all_product_transfer_item, get_product_transfer_item, update_product_transfer_item, delete_product_transfer_item

router = APIRouter(prefix="/product_transfer_item", tags=["product_transfer_item"])

@router.post("/", response_model=ProductTransferItemRead)
def create_new_product_transfer_item(product_transfer_item: ProductTransferItemCreate, session: Session = Depends(get_session)):
    return create_product_transfer_item(session, product_transfer_item)

@router.get("/", response_model=list[ProductTransferItemRead])
def read_product_transfer_items(session: Session = Depends(get_session)):
    return get_all_product_transfer_item(session)

@router.get("/{product_transfer_item_id}", response_model=ProductTransferItemRead)
def read_product_transfer_item(product_transfer_item_id: int, session: Session = Depends(get_session)):
    return get_product_transfer_item(session, product_transfer_item_id)

@router.put("/{product_transfer_item_id}", response_model=ProductTransferItemRead)
def update_product_transfer_item_route(
    product_transfer_item_id: int,
    product_transfer: ProductTransferItemUpdate,
    session: Session = Depends(get_session)
):
    return update_product_transfer_item(
        session,
        product_transfer_item_id,
        product_transfer
    )

@router.delete("/{product_transfer_item_id}")
def delete_product_transfer_item_route(product_transfer_item_id: int, session: Session = Depends(get_session)):
    return delete_product_transfer_item(session, product_transfer_item_id)