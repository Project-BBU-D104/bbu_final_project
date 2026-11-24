from sqlmodel import Session, select
from app.models.sale import Sale
from app.models.product import Product
from app.schemas.sale.sale import SaleCreate, SaleUpdate
from datetime import datetime, timezone
from decimal import Decimal
from sqlalchemy.orm import selectinload
from app.models.sale_items import SaleItems
from app.models.warehouse_stock import WarehouseStock
from app.models.user import User
from fastapi import HTTPException
from app.schemas.sale.sale_item import SaleItemCreate


def _stock_rows(session: Session, product_id: int, warehouse_id: int | None):
    statement = select(WarehouseStock).where(WarehouseStock.product_id == product_id)
    if warehouse_id is not None:
        statement = statement.where(WarehouseStock.warehouse_id == warehouse_id)
    return session.exec(statement.order_by(WarehouseStock.id).with_for_update()
                        .execution_options(populate_existing=True)).all()


def _decrease_warehouse_stock(session: Session, product: Product, item: SaleItemCreate) -> int:
    rows = _stock_rows(session, product.id, item.warehouse_id)
    if not rows:
        raise HTTPException(400, f'No warehouse stock for "{product.name}" in this selection.')
    if item.warehouse_id is None and len({row.warehouse_id for row in rows}) != 1:
        raise HTTPException(400, f'Select a warehouse for "{product.name}".')

    available = sum(row.qty for row in rows)
    if available < item.qty:
        raise HTTPException(400, f'Not enough stock for "{product.name}". '
                                 f'Only {available} left, but {item.qty} requested.')
    remaining = item.qty
    for row in rows:
        taken = min(remaining, max(0, row.qty))
        row.qty -= taken
        remaining -= taken
        if remaining == 0:
            break
    return rows[0].warehouse_id


def _restore_warehouse_stock(session: Session, item: SaleItems) -> None:
    if item.warehouse_id is None:
        raise HTTPException(409, f'Review product {item.product_id}: original warehouse is unknown.')
    rows = _stock_rows(session, item.product_id, item.warehouse_id)
    if not rows:
        raise HTTPException(409, f'Review product {item.product_id}: stock row for '
                                 f'warehouse {item.warehouse_id} is missing.')
    rows[0].qty += item.qty


def _locked_sale(session: Session, sale_id: int):
    return session.exec(select(Sale).where(Sale.id == sale_id).with_for_update()
                        .execution_options(populate_existing=True)).first()


def _locked_lines(session: Session, sale_id: int):
    return session.exec(select(SaleItems).where(SaleItems.sale_id == sale_id)
                        .order_by(SaleItems.id).with_for_update()
                        .execution_options(populate_existing=True)).all()


def _build_sale_items(
    session: Session, sale_id: int, sale_items: list[SaleItemCreate]
) -> tuple[list[SaleItems], Decimal]:
    items = []
    subtotal = Decimal("0.00")

    if not sale_items:
        return items, subtotal

    product_ids = {item.product_id for item in sale_items}
    products = {
        product.id: product
        for product in session.exec(
            select(Product).where(Product.id.in_(product_ids))
        ).all()
    }

    missing = product_ids - products.keys()
    if missing:
        raise HTTPException(
            status_code=404,
            detail=f"Product(s) {sorted(missing)} not found",
        )

    for item in sale_items:
        product = products[item.product_id]
        warehouse_id = _decrease_warehouse_stock(session, product, item)
        line_subtotal = product.sale_price * item.qty
        subtotal += line_subtotal
        items.append(SaleItems(
            sale_id=sale_id,
            product_id=product.id,
            warehouse_id=warehouse_id,
            qty=item.qty,
            sale_price=product.sale_price,
            subtotal=line_subtotal,
        ))

    return items, subtotal


def _set_sale_totals(db_sale: Sale) -> None:
    db_sale.total_amount = max(
        db_sale.subtotal + db_sale.tax_amount - db_sale.discount_amount,
        Decimal("0.00"),
    )
    db_sale.due_amount = max(db_sale.total_amount - db_sale.paid_amount, Decimal("0.00"))
    db_sale.payment_status = (
        "paid" if db_sale.due_amount == 0
        else "partial" if db_sale.paid_amount > 0
        else "unpaid"
    )

def generate_invoice_no(session: Session) -> str:
    """Return the next sale invoice number: SALE-YYYYMMDD-NNN.

    The sequence restarts at 001 each day.
    """
    today = datetime.now(timezone.utc).strftime("%Y%m%d")
    prefix = f"SALE-{today}-"

    last_sale = session.exec(
        select(Sale)
        .where(Sale.invoice_no.like(f"{prefix}%"))
        .order_by(Sale.id.desc())
    ).first()

    if last_sale is None:
        next_number = 1
    else:
        try:
            next_number = int(last_sale.invoice_no.removeprefix(prefix)) + 1
        except ValueError:
            next_number = 1

    return f"{prefix}{next_number:03d}"


def _stage_sale(session: Session, sale: SaleCreate) -> Sale:
    sale_data = sale.model_dump(
        exclude={"sale_items"},
        exclude_none=True,
    )
    invoice_no = (sale_data.get("invoice_no") or "").strip()
    sale_data["invoice_no"] = invoice_no or generate_invoice_no(session)
    db_sale = Sale.model_validate(sale_data)
    session.add(db_sale)
    session.flush()
    items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items)
    db_sale.sale_items.extend(items)
    _set_sale_totals(db_sale)
    session.flush()
    return db_sale


def create_sale(session: Session, sale: SaleCreate):
    try:
        db_sale = _stage_sale(session, sale)
        session.commit()
    except Exception:
        session.rollback()
        raise

    return get_sale(session, db_sale.id)

def get_all_sales(session: Session):
    statement = (
        select(Sale)
        .options(
            selectinload(Sale.user).selectinload(User.role),
            selectinload(Sale.customer),
            selectinload(Sale.sale_items)
            .selectinload(SaleItems.product)
            .selectinload(Product.unit)
        )
    )
    return session.exec(statement).all()

def get_sale(session: Session, sale_id: int):
    statement = (
        select(Sale)
        .where(Sale.id == sale_id)
        .options(
            selectinload(Sale.user).selectinload(User.role),
            selectinload(Sale.customer),
            selectinload(Sale.sale_items)
            .selectinload(SaleItems.product)
            .selectinload(Product.unit),
        )
    )
    return session.exec(statement).first()

def update_sale(session: Session, sale_id: int, sale: SaleUpdate):
    db_sale = _locked_sale(session, sale_id)
    if not db_sale:
        return db_sale

    try:
        updates = sale.model_dump(
            exclude_unset=True,
            exclude={"sale_items", "subtotal", "total_amount", "paid_amount", "due_amount", "payment_status"},
        )
        for field, value in updates.items():
            if value is not None:
                setattr(db_sale, field, value)

        if sale.sale_items is not None:
            # Put the old quantities back before deducting the new ones.
            old_items = _locked_lines(session, sale_id)
            for old_item in old_items:
                _restore_warehouse_stock(session, old_item)

            items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items)
            for old_item in old_items:
                session.delete(old_item)
            session.add_all(items)

        _set_sale_totals(db_sale)

        db_sale.updated_at = sale.updated_at or datetime.now(timezone.utc)
        session.add(db_sale)
        session.commit()
    except Exception:
        session.rollback()
        raise

    return get_sale(session, sale_id)

def delete_sale(session: Session, sale_id: int):

    sale = _locked_sale(session, sale_id)

    if not sale:
        return None

    try:
        # Put the sold quantities back into warehouse stock.
        for item in _locked_lines(session, sale_id):
            _restore_warehouse_stock(session, item)
            session.delete(item)

        # delete payments if exists
        for payment in sale.sale_payments:
            session.delete(payment)

        # delete sale
        session.delete(sale)
        session.commit()
    except Exception:
        session.rollback()
        raise

    return sale