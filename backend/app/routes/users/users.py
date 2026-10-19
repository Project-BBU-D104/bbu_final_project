from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.user.user import UserCreate, UserRead
from app.crud.user.user import create_user, get_all_users, get_user, update_user, delete_user

router = APIRouter(prefix="/users", tags=["users"])

CACHE_NS = "users"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=UserRead)
async def create_new_user(user: UserCreate, session: Session = Depends(get_session)):
    result = create_user(session, user)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[UserRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_users(session: Session = Depends(get_session)):
    return get_all_users(session)

@router.get("/{user_id}", response_model=UserRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_user(user_id: int, session: Session = Depends(get_session)):
    return get_user(session, user_id)

@router.put("/{user_id}", response_model=UserRead)
async def update_user_route(user_id: int, user: UserCreate, session: Session = Depends(get_session)):
    result = update_user(session, user_id, user)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{user_id}")
async def delete_user_route(user_id: int, session: Session = Depends(get_session)):
    result = delete_user(session, user_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result