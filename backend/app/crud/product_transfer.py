from sqlmodel import Session, select
from app.models.product_transfer import ProductTransfer
from app.schemas.product_transfer import ProductTransferCreate, ProductTransferUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def generate_ref_no(session: Session) -> str:
    # Get the latest product transfer
    last_product_transfer = session.exec(
        select(ProductTransfer).order_by(ProductTransfer.id.desc())
    ).first()

    if last_product_transfer is None:
        return "PT001"

    # If previous invoice is PT001 -> number = 1
    try:
        last_number = int(last_product_transfer.reference_no.replace("PT", ""))
    except:
        last_number = last_product_transfer.id

    return f"PT{last_number + 1:04d}"

def create_product_transfer(session: Session, product_transfer: ProductTransferCreate):

    data = product_transfer.model_dump()

    if not data.get("reference_no"):
        data["reference_no"] = generate_ref_no(session)

    db_product_transfer = ProductTransfer(**data)

    session.add(db_product_transfer)
    session.commit()
    session.refresh(db_product_transfer)
    return db_product_transfer

def get_all_product_transfers(session: Session):
    statement = (
        select(ProductTransfer)
        .options(
            selectinload(ProductTransfer.product),
            selectinload(ProductTransfer.from_warehouse),
            selectinload(ProductTransfer.to_warehouse),
        )
    )
    return session.exec(statement).all()

def get_product_transfers(session: Session, product_transfer_id: int):
    statement = (
        select(ProductTransfer)
        .where(ProductTransfer.id == product_transfer_id)
        .options(
            selectinload(ProductTransfer.product),
            selectinload(ProductTransfer.from_warehouse),
            selectinload(ProductTransfer.to_warehouse),
        )
    )
    return session.exec(statement).first()

def update_product_transfer(session: Session, product_transfer_id: int, product_transfer: ProductTransferUpdate):
    db_product_transfer = session.get(ProductTransfer, product_transfer_id)
    if db_product_transfer:
        if product_transfer.from_warehouse_id is not None:
            db_product_transfer.from_warehouse_id = product_transfer.from_warehouse_id
        if product_transfer.to_warehouse_id is not None:
            db_product_transfer.to_warehouse_id = product_transfer.to_warehouse_id
        if product_transfer.product_id is not None:
            db_product_transfer.product_id = product_transfer.product_id
        if product_transfer.reference_no is not None:
            db_product_transfer.reference_no = product_transfer.reference_no
        if product_transfer.qty is not None:
            db_product_transfer.qty = product_transfer.qty
        if product_transfer.transfer_date is not None:
            db_product_transfer.transfer_date = product_transfer.transfer_date

        db_product_transfer.updated_at = product_transfer.updated_at or datetime.utcnow()
        session.add(db_product_transfer)
        session.commit()
        session.refresh(db_product_transfer)
    return db_product_transfer

def delete_product_transfer(session: Session, product_transfer_id: int):
    product_transfer = session.get(ProductTransfer, product_transfer_id)
    if product_transfer:
        session.delete(product_transfer)
        session.commit()
    return product_transfer