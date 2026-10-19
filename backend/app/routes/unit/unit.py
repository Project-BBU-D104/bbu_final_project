from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from sqlmodel import Session
from database import get_session
from app.schemas.unit.unit import UnitCreate, UnitRead, UnitUpdate
from app.crud.unit.unit import  create_unit, get_all_unit, get_unit, update_unit, delete_unit

router = APIRouter(prefix="/unit", tags=["unit"])

CACHE_NS = "unit"
CACHE_TTL = 60  # seconds

@router.post("/", response_model=UnitRead)
async def create_new_unit(unit: UnitCreate, session: Session = Depends(get_session)):
    result = create_unit(session, unit)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[UnitRead])
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_all_unit(session: Session = Depends(get_session)):
    return get_all_unit(session)

@router.get("/{unit_id}", response_model=UnitRead)
@cache(expire=CACHE_TTL, namespace=CACHE_NS)
async def read_unit(unit_id: int, session: Session = Depends(get_session)):
    return get_unit(session, unit_id)

@router.put("/{unit_id}", response_model=UnitRead)
async def update_unit_route(unit_id: int, unit: UnitUpdate, session: Session = Depends(get_session)):
    result = update_unit(session, unit_id, unit)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{unit_id}")
async def delete_unit_route(unit_id: int, session: Session = Depends(get_session)):
    result = delete_unit(session, unit_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result