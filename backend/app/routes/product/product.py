from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.product.product import ProductCreate,ProductRead,ProductUpdate
from app.crud.product.product import  create_product, get_all_product as get_all_products, get_product, update_product, delete_product

router = APIRouter(prefix="/product", tags=["product"])

@router.post("/", response_model=ProductRead)
def create_new_product(product: ProductCreate, session: Session = Depends(get_session)):
    return create_product(session, product)

@router.get("/", response_model=list[ProductRead])
def read_products(session: Session = Depends(get_session)):
    return get_all_products(session)

@router.get("/{product_id}", response_model=ProductRead)
def read_product(product_id: int, session: Session = Depends(get_session)):
    return get_product(session, product_id)

@router.put("/{product_id}", response_model=ProductRead)
def update_product_route(product_id: int, product: ProductUpdate, session: Session = Depends(get_session)):
    return update_product(session, product_id, product)

@router.delete("/{product_id}")
def delete_product_route(product_id: int, session: Session = Depends(get_session)):
    return delete_product(session, product_id)