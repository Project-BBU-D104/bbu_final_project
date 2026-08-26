from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.supplier.supplier import SupplierCreate, SupplierRead, SupplierUpdate
from app.crud.supplier.supplier import  create_supplier, get_all_supplier, get_supplier, update_supplier, delete_supplier

router = APIRouter(prefix="/supplier", tags=["supplier"])

@router.post("/", response_model=SupplierRead)
def create_new_supplier(supplier: SupplierCreate, session: Session = Depends(get_session)):
    return create_supplier(session, supplier)

@router.get("/", response_model=list[SupplierRead])
def read_all_supplier(session: Session = Depends(get_session)):
    return get_all_supplier(session)

@router.get("/{supplier_id}", response_model=SupplierRead)
def read_supplier(supplier_id: int, session: Session = Depends(get_session)):
    return get_supplier(session, supplier_id)

@router.put("/{supplier_id}", response_model=SupplierRead)
def update_supplier_route(supplier_id: int, supplier: SupplierUpdate, session: Session = Depends(get_session)):
    return update_supplier(session, supplier_id, supplier)

@router.delete("/{supplier_id}")
def delete_supplier_route(supplier_id: int, session: Session = Depends(get_session)):
    return delete_supplier(session, supplier_id)