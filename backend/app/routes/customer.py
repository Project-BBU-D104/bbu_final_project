from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.customer import CustomerCreate, CustomerRead, CustomerUpdate
from app.crud.customer import  create_customer, get_all_customer, get_customer, update_customer, delete_customer

router = APIRouter(prefix="/customer", tags=["customer"])

@router.post("/", response_model=CustomerRead)
def create_new_customer(customer: CustomerCreate, session: Session = Depends(get_session)):
    return create_customer(session, customer)

@router.get("/", response_model=list[CustomerRead])
def read_all_customer(session: Session = Depends(get_session)):
    return get_all_customer(session)

@router.get("/{customer_id}", response_model=CustomerRead)
def read_customer(customer_id: int, session: Session = Depends(get_session)):
    return get_customer(session, customer_id)

@router.put("/{customer_id}", response_model=CustomerRead)
def update_customer_route(customer_id: int, customer: CustomerUpdate, session: Session = Depends(get_session)):
    return update_customer(session, customer_id, customer)

@router.delete("/{customer_id}")
def delete_customer_route(customer_id: int, session: Session = Depends(get_session)):
    return delete_customer(session, customer_id)