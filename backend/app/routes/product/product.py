from fastapi import APIRouter, Depends
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.product.product import ProductCreate,ProductRead,ProductUpdate
from app.crud.product.product import  create_product, get_all_product as get_all_products, get_product, update_product, delete_product
from app.core.cache import clear_stock_caches

router = APIRouter(prefix="/product", tags=["product"])

CACHE_NS = "product"
CACHE_TTL = 60

@router.post("/", response_model=ProductRead)
async def create_new_product(product: ProductCreate, session: Session = Depends(get_session)):
    result = create_product(session, product)
    await clear_stock_caches()  # clears this namespace and warehouse
    return result

@router.get("/", response_model=list[ProductRead])
@cache(namespace=CACHE_NS, expire=CACHE_TTL)
async def read_products(session: Session = Depends(get_session)):
    return get_all_products(session)

@router.get("/{product_id}", response_model=ProductRead)
@cache(namespace=CACHE_NS, expire=CACHE_TTL)
async def read_product(product_id: int, session: Session = Depends(get_session)):
    return get_product(session, product_id)

@router.put("/{product_id}", response_model=ProductRead)
async def update_product_route(product_id: int, product: ProductUpdate, session: Session = Depends(get_session)):
    result = update_product(session, product_id, product)
    await clear_stock_caches()  # clears this namespace and warehouse
    return result

@router.delete("/{product_id}")
async def delete_product_route(product_id: int, session: Session = Depends(get_session)):
    result = delete_product(session, product_id)
    await clear_stock_caches()  # clears this namespace and warehouse
    return result