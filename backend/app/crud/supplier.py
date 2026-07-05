from sqlmodel import Session, select
from app.models.supplier import Supplier
from app.schemas.supplier import SupplierCreate, SupplierUpdate
from datetime import datetime

def create_supplier(session: Session, supplier: SupplierCreate):
    db_supplier = Supplier.from_orm(supplier)
    session.add(db_supplier)
    session.commit()
    session.refresh(db_supplier)
    return db_supplier

def get_all_supplier(session: Session):
    return session.exec(select(Supplier)).all()

def get_supplier(session: Session, supplier_id: int):
    return session.get(Supplier, supplier_id)

def update_supplier(session: Session, supplier_id: int, supplier: SupplierUpdate):
    db_supplier = session.get(Supplier, supplier_id)
    if db_supplier:
        if supplier.name is not None:
            db_supplier.name = supplier.name
        if supplier.phone is not None:
            db_supplier.phone = supplier.phone
        if supplier.email is not None:
            db_supplier.email = supplier.email
        if supplier.map is not None:
            db_supplier.map = supplier.map
        if supplier.address is not None:
            db_supplier.address = supplier.address
        if supplier.status is not None:
            db_supplier.status = supplier.status

        db_supplier.updated_at = supplier.updated_at or datetime.utcnow()
        session.add(db_supplier)
        session.commit()
        session.refresh(db_supplier)
    return db_supplier

def delete_supplier(session: Session, supplier_id: int):
    supplier = session.get(Supplier, supplier_id)
    if supplier:
        session.delete(supplier)
        session.commit()
    return supplier