from datetime import datetime, timezone
from fastapi import HTTPException
from sqlalchemy.orm import selectinload
from sqlmodel import Session, select
from app.models.product_transfer import ProductTransfer
from app.models.product_transfer_item import ProductTransferItem
from app.models.warehouse_stock import WarehouseStock
from app.schemas.product_transfer.product_transfer import (
    ProductTransferCreate,
    ProductTransferUpdate,
)
from app.schemas.product_transfer.product_transfer_item import ProductTransferItemInput
from sqlalchemy.orm import selectinload


def generate_ref_no(session: Session) -> str:
    last_transfer = session.exec(
        select(ProductTransfer).order_by(ProductTransfer.id.desc())
    ).first()
    if last_transfer is None:
        return "PT0001"

    try:
        last_number = int(last_transfer.reference_no.removeprefix("PT"))
    except (TypeError, ValueError):
        last_number = last_transfer.id or 0
    return f"PT{last_number + 1:04d}"


def _stock(session: Session, warehouse_id: int, product_id: int):
    return session.exec(
        select(WarehouseStock)
        .where(
            WarehouseStock.warehouse_id == warehouse_id,
            WarehouseStock.product_id == product_id,
        )
        .with_for_update()
    ).first()


def _validate_transfer(from_warehouse_id: int, to_warehouse_id: int) -> None:
    if from_warehouse_id == to_warehouse_id:
        raise HTTPException(
            status_code=400,
            detail="Source and destination warehouses must be different.",
        )


def _move_stock(
    session: Session,
    from_warehouse_id: int,
    to_warehouse_id: int,
    product_id: int,
    qty: int,
) -> None:
    _validate_transfer(from_warehouse_id, to_warehouse_id)
    source = _stock(session, from_warehouse_id, product_id)
    if source is None:
        raise HTTPException(
            status_code=400,
            detail=f"Product {product_id} has no stock in the source warehouse.",
        )
    if source.qty < qty:
        raise HTTPException(
            status_code=400,
            detail=f"Insufficient stock for product {product_id}.",
        )

    destination = _stock(session, to_warehouse_id, product_id)
    source.qty -= qty
    if destination is None:
        session.add(
            WarehouseStock(
                warehouse_id=to_warehouse_id,
                product_id=product_id,
                qty=qty,
            )
        )
    else:
        destination.qty += qty


def _reverse_stock(
    session: Session,
    from_warehouse_id: int,
    to_warehouse_id: int,
    product_id: int,
    qty: int,
) -> None:
    destination = _stock(session, to_warehouse_id, product_id)
    if destination is None or destination.qty < qty:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Cannot reverse transfer: destination stock for product "
                f"{product_id} has already been used."
            ),
        )

    source = _stock(session, from_warehouse_id, product_id)
    destination.qty -= qty
    if source is None:
        session.add(
            WarehouseStock(
                warehouse_id=from_warehouse_id,
                product_id=product_id,
                qty=qty,
            )
        )
    else:
        source.qty += qty


def _lines_by_product(items):
    lines = {}
    for item in items:
        if item.product_id in lines:
            raise HTTPException(
                status_code=422,
                detail=f"Product {item.product_id} appears more than once.",
            )
        if item.qty <= 0:
            raise HTTPException(status_code=422, detail="Item quantities must be positive.")
        lines[item.product_id] = item.qty
    return lines


def _transfer_statement():
    return select(ProductTransfer).options(
        selectinload(ProductTransfer.from_warehouse),
        selectinload(ProductTransfer.to_warehouse),
        selectinload(ProductTransfer.product_transfer_items).selectinload(
            ProductTransferItem.product
        ),
    )


def create_product_transfer(session: Session, product_transfer: ProductTransferCreate):
    data = product_transfer.model_dump(exclude={"product_transfer_items"})
    _validate_transfer(data["from_warehouse_id"], data["to_warehouse_id"])
    lines = _lines_by_product(product_transfer.product_transfer_items)
    if not data.get("reference_no"):
        data["reference_no"] = generate_ref_no(session)

    db_transfer = ProductTransfer(**data)
    try:
        session.add(db_transfer)
        session.flush()
        for product_id, qty in lines.items():
            _move_stock(
                session,
                db_transfer.from_warehouse_id,
                db_transfer.to_warehouse_id,
                product_id,
                qty,
            )
            session.add(
                ProductTransferItem(
                    product_transfer_id=db_transfer.id,
                    product_id=product_id,
                    qty=qty,
                )
            )
        session.commit()
    except Exception:
        session.rollback()
        raise
    return get_product_transfers(session, db_transfer.id)

def get_all_product_transfers(session: Session):
    return session.exec(_transfer_statement().order_by(ProductTransfer.id.desc())).all()

def get_product_transfers(session: Session, product_transfer_id: int):
    statement = _transfer_statement().where(ProductTransfer.id == product_transfer_id)
    return session.exec(statement).first()

def update_product_transfer(session: Session, product_transfer_id: int, product_transfer: ProductTransferUpdate):
    db_transfer = session.exec(
        _transfer_statement().where(ProductTransfer.id == product_transfer_id)
    ).first()
    if db_transfer is None:
        return None

    data = product_transfer.model_dump(
        exclude_unset=True,
        exclude={"product_transfer_items"},
    )
    new_from = data.get("from_warehouse_id", db_transfer.from_warehouse_id)
    new_to = data.get("to_warehouse_id", db_transfer.to_warehouse_id)
    if new_from is None or new_to is None:
        raise HTTPException(
            status_code=422,
            detail="Source and destination warehouses are required.",
        )
    _validate_transfer(new_from, new_to)

    old_lines = _lines_by_product(db_transfer.product_transfer_items)
    if product_transfer.product_transfer_items is None:
        new_lines = old_lines
    else:
        new_lines = _lines_by_product(product_transfer.product_transfer_items)
        if not new_lines:
            raise HTTPException(status_code=422, detail="A transfer must contain at least one item.")

    locations_changed = (
        new_from != db_transfer.from_warehouse_id
        or new_to != db_transfer.to_warehouse_id
    )
    try:
        if locations_changed:
            for product_id, qty in old_lines.items():
                _reverse_stock(
                    session,
                    db_transfer.from_warehouse_id,
                    db_transfer.to_warehouse_id,
                    product_id,
                    qty,
                )
            for product_id, qty in new_lines.items():
                _move_stock(session, new_from, new_to, product_id, qty)
        elif product_transfer.product_transfer_items is not None:
            for product_id in old_lines.keys() | new_lines.keys():
                old_qty = old_lines.get(product_id, 0)
                new_qty = new_lines.get(product_id, 0)
                if new_qty > old_qty:
                    _move_stock(
                        session,
                        new_from,
                        new_to,
                        product_id,
                        new_qty - old_qty,
                    )
                elif old_qty > new_qty:
                    _reverse_stock(
                        session,
                        new_from,
                        new_to,
                        product_id,
                        old_qty - new_qty,
                    )

        for field, value in data.items():
            setattr(db_transfer, field, value)
        db_transfer.updated_at = product_transfer.updated_at or datetime.now(timezone.utc)

        if product_transfer.product_transfer_items is not None:
            db_transfer.product_transfer_items.clear()
            for product_id, qty in new_lines.items():
                db_transfer.product_transfer_items.append(
                    ProductTransferItem(product_id=product_id, qty=qty)
                )

        session.add(db_transfer)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return get_product_transfers(session, product_transfer_id)

def delete_product_transfer(session: Session, product_transfer_id: int):
    transfer = session.exec(
        _transfer_statement().where(ProductTransfer.id == product_transfer_id)
    ).first()
    if transfer is None:
        return None
    if not transfer.product_transfer_items:
        raise HTTPException(
            status_code=400,
            detail=(
                "This transfer has no saved items, so its stock cannot be "
                "restored. The transfer was not deleted."
            ),
        )

    try:
        for product_id, qty in _lines_by_product(transfer.product_transfer_items).items():
            _reverse_stock(
                session,
                transfer.from_warehouse_id,
                transfer.to_warehouse_id,
                product_id,
                qty,
            )
        session.delete(transfer)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return transfer