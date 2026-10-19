from sqlmodel import Session, select
from app.models.sale import Sale
from app.models.product import Product
from app.schemas.sale.sale import SaleCreate, SaleUpdate
from datetime import datetime, timezone
from decimal import Decimal
from sqlalchemy.orm import selectinload
from app.models.sale_items import SaleItems
from app.models.user import User
from fastapi import HTTPException
from app.schemas.sale.sale_item import SaleItemCreate


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
        line_subtotal = product.sale_price * item.qty
        subtotal += line_subtotal
        items.append(SaleItems(
            sale_id=sale_id,
            product_id=product.id,
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

def create_sale(session: Session, sale: SaleCreate):
    sale_data = sale.model_dump(
        exclude={"sale_items"},
        exclude_none=True,
    )
    db_sale = Sale.model_validate(sale_data)
    try:
        session.add(db_sale)
        session.flush()
        items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items)
        db_sale.sale_items.extend(items)
        _set_sale_totals(db_sale)
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
            selectinload(Sale.sale_items).selectinload(SaleItems.product),
        )
    )
    return session.exec(statement).first()

def update_sale(session: Session, sale_id: int, sale: SaleUpdate):
    statement = select(Sale).where(Sale.id == sale_id).options(selectinload(Sale.sale_items))
    db_sale = session.exec(statement).first()
    if db_sale:
        updates = sale.model_dump(
            exclude_unset=True,
            exclude={"sale_items", "subtotal", "total_amount", "due_amount", "payment_status"},
        )
        for field, value in updates.items():
            if value is not None:
                setattr(db_sale, field, value)

        if sale.sale_items is not None:
            items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items)
            for old_item in db_sale.sale_items:
                session.delete(old_item)
            db_sale.sale_items = items

        _set_sale_totals(db_sale)

        db_sale.updated_at = sale.updated_at or datetime.now(timezone.utc)
        session.add(db_sale)
        session.commit()
        return get_sale(session, sale_id)
    return db_sale

def delete_sale(session: Session, sale_id: int):

    sale = session.get(Sale, sale_id)

    if not sale:
        return None

    # delete sale items first
    for item in sale.sale_items:
        session.delete(item)

    # delete payments if exists
    for payment in sale.sale_payments:
        session.delete(payment)

    # delete sale
    session.delete(sale)
    session.commit()
    return sale