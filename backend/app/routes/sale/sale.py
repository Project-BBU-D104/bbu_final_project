from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.sale.sale import SaleCreate,SaleRead,SaleUpdate
from app.crud.sale.sale import  create_sale, get_all_sales, get_sale, update_sale, delete_sale

router = APIRouter(prefix="/sale", tags=["sale"])

@router.post("/", response_model=SaleRead)
def create_new_sale(payment: SaleCreate, session: Session = Depends(get_session)):
    return create_sale(session, payment)

@router.get("/", response_model=list[SaleRead])
def read_sales(session: Session = Depends(get_session)):
    return get_all_sales(session)

@router.get("/{sale_id}", response_model=SaleRead)
def read_sale(sale_id: int, session: Session = Depends(get_session)):
    return get_sale(session, sale_id)

@router.put("/{sale_id}", response_model=SaleRead)
def update_sale_route(sale_id: int, sale: SaleUpdate, session: Session = Depends(get_session)):
    return update_sale(session, sale_id, sale)

@router.delete("/{sale_id}")
def delete_sale_route(sale_id: int, session: Session = Depends(get_session)):
    return delete_sale(session, sale_id)