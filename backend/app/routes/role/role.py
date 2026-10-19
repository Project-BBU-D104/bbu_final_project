from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.role.role import RoleCreate, RoleRead, RoleUpdate
from app.crud.role.role import  create_role, get_all_role, get_role, update_role, delete_role

router = APIRouter(prefix="/role", tags=["role"])

CACHE_NS = "role"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=RoleRead)
async def create_new_role(role: RoleCreate, session: Session = Depends(get_session)):
    result = create_role(session, role)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[RoleRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_role(session: Session = Depends(get_session)):
    return get_all_role(session)

@router.get("/{role_id}", response_model=RoleRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_role(role_id: int, session: Session = Depends(get_session)):
    return get_role(session, role_id)

@router.put("/{role_id}", response_model=RoleRead)
async def update_role_route(role_id: int, role: RoleUpdate, session: Session = Depends(get_session)):
    result =update_role(session, role_id, role)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{role_id}")
async def delete_role_route(role_id: int, session: Session = Depends(get_session)):
    result = delete_role(session, role_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result