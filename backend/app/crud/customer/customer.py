from sqlmodel import Session, select
from app.models.customer import Customer
from app.schemas.customer.customer import CustomerCreate, CustomerUpdate
from datetime import datetime

def create_customer(session: Session, customer: CustomerCreate):
    db_customer = Customer.from_orm(customer)
    session.add(db_customer)
    session.commit()
    session.refresh(db_customer)
    return db_customer

def get_all_customer(session: Session):
    return session.exec(select(Customer)).all()

def get_customer(session: Session, customer_id: int):
    return session.get(Customer, customer_id)

def update_customer(session: Session, customer_id: int, customer: CustomerUpdate):
    db_customer = session.get(Customer, customer_id)
    if db_customer:
        if customer.name is not None:
            db_customer.name = customer.name
        if customer.photo is not None:
            db_customer.photo = customer.photo
        if customer.is_active is not None:
            db_customer.is_active = customer.is_active
        if customer.phone is not None:
            db_customer.phone = customer.phone
        if customer.address is not None:
            db_customer.address = customer.address

        db_customer.updated_at = customer.updated_at or datetime.utcnow()
        session.add(db_customer)
        session.commit()
        session.refresh(db_customer)
    return db_customer

def delete_customer(session: Session, customer_id: int):
    customer = session.get(Customer, customer_id)
    if customer:
        session.delete(customer)
        session.commit()
    return customer