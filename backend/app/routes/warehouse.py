from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.warehouse import WarehouseCreate, WarehouseRead, WarehouseUpdate
from app.crud.warehouse import  create_warehouse, get_all_warehouse, get_warehouse, update_warehouse, delete_warehouse

router = APIRouter(prefix="/warehouse", tags=["warehouse"])

@router.post("/", response_model=WarehouseRead)
def create_new_warehouse(warehouse: WarehouseCreate, session: Session = Depends(get_session)):
    return create_warehouse(session, warehouse)

@router.get("/", response_model=list[WarehouseRead])
def read_all_warehouse(session: Session = Depends(get_session)):
    return get_all_warehouse(session)

@router.get("/{warehouse_id}", response_model=WarehouseRead)
def read_warehouse(warehouse_id: int, session: Session = Depends(get_session)):
    return get_warehouse(session, warehouse_id)

@router.put("/{warehouse_id}", response_model=WarehouseRead)
def update_warehouse_route(warehouse_id: int, warehouse: WarehouseUpdate, session: Session = Depends(get_session)):
    return update_warehouse(session, warehouse_id, warehouse)

@router.delete("/{warehouse_id}")
def delete_warehouse_route(warehouse_id: int, session: Session = Depends(get_session)):
    return delete_warehouse(session, warehouse_id)