from sqlmodel import Session, select
from app.models.warehouse import Warehouse
from app.schemas.warehouse import WarehouseCreate, WarehouseUpdate
from datetime import datetime

def generate_reference_no(session: Session) -> str:
    # Get the latest warehouse
    last_warehouse = session.exec(
        select(Warehouse).order_by(Warehouse.id.desc())
    ).first()

    if last_warehouse is None:
        return "WH001"

    # If previous invoice is WH001 -> number = 1
    try:
        last_number = int(last_warehouse.reference_no.replace("WH", ""))
    except:
        last_number = last_warehouse.id

    return f"WH{last_number + 1:04d}"

def create_warehouse(session: Session, warehouse: WarehouseCreate):
    warehouse_data = warehouse.model_dump()

    if not warehouse_data.get("reference_no"):
        warehouse_data["reference_no"] = generate_reference_no(session)

    db_warehouse = Warehouse(**warehouse_data)

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
        if warehouse.note is not None:
            db_warehouse.note = warehouse.note
        if warehouse.reference_no is not None:
            db_warehouse.reference_no = warehouse.reference_no

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