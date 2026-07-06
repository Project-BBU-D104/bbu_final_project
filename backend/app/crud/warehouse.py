from sqlmodel import Session, select
from app.models.warehouse import Warehouse
from app.schemas.warehouse import WarehouseCreate, WarehouseUpdate
from datetime import datetime

def create_warehouse(session: Session, warehouse: WarehouseCreate):
    db_warehouse = Warehouse.from_orm(warehouse)
    session.add(db_warehouse)
    session.commit()
    session.refresh(db_warehouse)
    return db_warehouse

def get_all_warehouse(session: Session):
    return session.exec(select(Warehouse)).all()

def get_warehouse(session: Session, warehouse_id: int):
    return session.get(Warehouse, warehouse_id)

def update_warehouse(session: Session, warehouse_id: int, warehouse: WarehouseUpdate):
    db_warehouse = session.get(Warehouse, warehouse_id)
    if db_warehouse:
        if warehouse.name is not None:
            db_warehouse.name = warehouse.name
        if warehouse.location is not None:
            db_warehouse.location = warehouse.location

        db_warehouse.updated_at = warehouse.updated_at or datetime.utcnow()
        session.add(db_warehouse)
        session.commit()
        session.refresh(db_warehouse)
    return db_warehouse

def delete_warehouse(session: Session, warehouse_id: int):
    warehouse = session.get(Warehouse, warehouse_id)
    if warehouse:
        session.delete(warehouse)
        session.commit()
    return warehouse