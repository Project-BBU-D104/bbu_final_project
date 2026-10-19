from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.category.category import CategoryCreate, CategoryRead, CategoryUpdate
from app.crud.category.category import  create_category, get_all_category, get_category, update_category, delete_category

router = APIRouter(prefix="/category", tags=["category"])

CACHE_NS = "category"
CACHE_TTL = 60  # seconds


@router.post("/", response_model=CategoryRead)
async def create_new_category(category: CategoryCreate, session: Session = Depends(get_session)):
    result = create_category(session, category)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[CategoryRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_category(session: Session = Depends(get_session)):
    return get_all_category(session)


@router.get("/{category_id}", response_model=CategoryRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_category(category_id: int, session: Session = Depends(get_session)):
    return get_category(session, category_id)


@router.put("/{category_id}", response_model=CategoryRead)
async def update_category_route(category_id: int, category: CategoryUpdate, session: Session = Depends(get_session)):
    result = update_category(session, category_id, category)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result


@router.delete("/{category_id}")
async def delete_category_route(category_id: int, session: Session = Depends(get_session)):
    result = delete_category(session, category_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result
