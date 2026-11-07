from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from sqlmodel import Session
from database import get_session
from app.schemas.sale.sale_payment import SalePaymentCreate,SalePaymentRead,SalePaymentUpdate
from app.crud.sale.sale_payment import create_sale_payment, get_all_sale_payments, get_sale_payment, update_sale_payment, delete_sale_payment

router = APIRouter(prefix="/sale_payment", tags=["sale_payment"])

CACHE_NS = "sale"  # payments change the SaleRead payload served by /sale

@router.post("/", response_model=SalePaymentRead)
async def create_new_sale(sale_payment: SalePaymentCreate, session: Session = Depends(get_session)):
    result = create_sale_payment(session, sale_payment)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.get("/", response_model=list[SalePaymentRead])
def read_sale_payments(session: Session = Depends(get_session)):
    return get_all_sale_payments(session)

@router.get("/{sale_payment_id}", response_model=SalePaymentRead)
def read_sale_payment(sale_payment_id: int, session: Session = Depends(get_session)):
    return get_sale_payment(session, sale_payment_id)

@router.put("/{sale_payment_id}", response_model=SalePaymentRead)
async def update_sale_payment_route(sale_payment_id: int, sale: SalePaymentUpdate, session: Session = Depends(get_session)):
    result = update_sale_payment(session, sale_payment_id, sale)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result

@router.delete("/{sale_payment_id}")
async def delete_sale_payment_route(sale_payment_id: int, session: Session = Depends(get_session)):
    result = delete_sale_payment(session, sale_payment_id)
    await FastAPICache.clear(namespace=CACHE_NS)
    return result