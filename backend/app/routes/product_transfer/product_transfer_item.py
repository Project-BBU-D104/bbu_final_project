from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from database import get_session
from app.schemas.product_transfer.product_transfer_item import ProductTransferItemCreate,ProductTransferItemRead,ProductTransferItemUpdate
from app.crud.product_transfer.product_transfer_item import  create_product_transfer_item, get_all_product_transfer_item, get_product_transfer_item, update_product_transfer_item, delete_product_transfer_item
from app.core.cache import clear_stock_caches

router = APIRouter(prefix="/product_transfer_item", tags=["product_transfer_item"])

@router.post("/", response_model=ProductTransferItemRead)
async def create_new_product_transfer_item(product_transfer_item: ProductTransferItemCreate, session: Session = Depends(get_session)):
    result = create_product_transfer_item(session, product_transfer_item)
    await clear_stock_caches()
    return result

@router.get("/", response_model=list[ProductTransferItemRead])
def read_product_transfer_items(session: Session = Depends(get_session)):
    return get_all_product_transfer_item(session)

@router.get("/{product_transfer_item_id}", response_model=ProductTransferItemRead)
def read_product_transfer_item(product_transfer_item_id: int, session: Session = Depends(get_session)):
    item = get_product_transfer_item(session, product_transfer_item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Transfer item not found.")
    return item

@router.put("/{product_transfer_item_id}", response_model=ProductTransferItemRead)
async def update_product_transfer_item_route(
    product_transfer_item_id: int,
    product_transfer: ProductTransferItemUpdate,
    session: Session = Depends(get_session)
):
    item = update_product_transfer_item(
        session,
        product_transfer_item_id,
        product_transfer
    )
    if item is None:
        raise HTTPException(status_code=404, detail="Transfer item not found.")
    await clear_stock_caches()
    return item

@router.delete("/{product_transfer_item_id}")
async def delete_product_transfer_item_route(product_transfer_item_id: int, session: Session = Depends(get_session)):
    item = delete_product_transfer_item(session, product_transfer_item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Transfer item not found.")
    await clear_stock_caches()
    return {"message": "Transfer item deleted successfully."}