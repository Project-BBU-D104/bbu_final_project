from sqlmodel import Session, select
from app.models.sale import Sale
from app.models.product import Product
from app.schemas.sale.sale import ConvertedSaleCheckoutCreate, SaleCheckoutCreate, SaleCreate, SaleUpdate
from datetime import datetime, timezone
from decimal import Decimal, DecimalException, ROUND_HALF_UP
from sqlalchemy.orm import selectinload
from app.models.sale_items import SaleItems
from app.models.sale_payment import SalePayment
from app.models.warehouse_stock import WarehouseStock
from app.models.user import User
from app.models.currency import Currency
from app.models.system_configuration import SystemConfiguration
from fastapi import HTTPException
from app.schemas.sale.sale_item import SaleItemCreate


def _warehouse_stock_for_product(session: Session, product_id: int):
    return session.exec(
        select(WarehouseStock).where(WarehouseStock.product_id == product_id)
    ).first()


def _decrease_warehouse_stock(
    session: Session, product: Product, quantity: int
) -> None:
    stock = _warehouse_stock_for_product(session, product.id)

    if stock is None:
        raise HTTPException(
            status_code=400,
            detail=f'Product "{product.name}" is not in any warehouse stock.',
        )

    if stock.qty < quantity:
        raise HTTPException(
            status_code=400,
            detail=(
                f'Not enough stock for "{product.name}". '
                f'Only {stock.qty} left, but {quantity} requested.'
            ),
        )

    stock.qty -= quantity
    session.add(stock)


def _restore_warehouse_stock(
    session: Session, product_id: int, quantity: int
) -> None:
    stock = _warehouse_stock_for_product(session, product_id)
    if stock is None:
        return

    stock.qty += quantity
    session.add(stock)


def _build_sale_items(
    session: Session, sale_id: int, sale_items: list[SaleItemCreate],
    settlement_currency: Currency | None = None,
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

    currencies = {}
    if settlement_currency is not None:
        ids = {product.currency_id for product in products.values()}
        currencies = {
            currency.id: currency
            for currency in session.exec(select(Currency).where(Currency.id.in_(ids))).all()
        }

    for item in sale_items:
        product = products[item.product_id]
        _decrease_warehouse_stock(session, product, item.qty)
        unit_price = product.sale_price
        line_subtotal = unit_price * item.qty
        original = {}
        if settlement_currency is not None:
            source = currencies.get(product.currency_id)
            if source is None:
                raise HTTPException(status_code=400, detail="Product currency is unavailable.")
            unit_price = _converted_amount(product.sale_price, source, settlement_currency, allow_zero=True)
            line_subtotal = _converted_amount(product.sale_price * item.qty, source, settlement_currency)
            original = {
                "original_unit_price": product.sale_price,
                "original_currency_code": source.code,
                "original_currency_symbol": source.symbol,
            }
        subtotal += line_subtotal
        items.append(SaleItems(
            sale_id=sale_id,
            product_id=product.id,
            qty=item.qty,
            sale_price=unit_price,
            subtotal=line_subtotal,
            **original,
        ))

    return items, subtotal


def _currency_rate(currency: Currency) -> Decimal:
    try:
        rate = Decimal(str(currency.exchange_rate))
    except (DecimalException, ValueError, TypeError):
        raise HTTPException(status_code=400, detail="A currency exchange rate is invalid.")
    if not rate.is_finite() or rate <= 0:
        raise HTTPException(status_code=400, detail="A currency exchange rate is invalid.")
    return rate


def _converted_amount(price: Decimal, source: Currency, target: Currency, allow_zero: bool = False) -> Decimal:
    try:
        amount = Decimal(str(price))
        if not amount.is_finite() or amount < 0:
            raise ValueError("Invalid product price")
        rate = _currency_rate(target) / _currency_rate(source)
        precision = Decimal("1") if target.code.upper() == "KHR" else Decimal("0.01")
        converted = (amount * rate).quantize(precision, rounding=ROUND_HALF_UP)
        if amount > 0 and converted == 0 and not allow_zero:
            raise HTTPException(status_code=400, detail="A product price is too small in the sale currency.")
        return converted
    except (DecimalException, ValueError, TypeError):
        raise HTTPException(status_code=400, detail="Unable to convert a product price.")


def _sale_currency(session: Session, user_id: int) -> Currency:
    user = session.get(User, user_id)
    config = session.get(SystemConfiguration, user.system_configuration_id) if user and user.system_configuration_id else None
    currency = session.get(Currency, config.default_currency_id) if config else None
    if currency is None:
        raise HTTPException(status_code=400, detail="The user's system configuration has no sale currency.")
    _currency_rate(currency)
    return currency


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


def _add_sale(session: Session, sale: SaleCreate, settlement_currency: Currency | None = None) -> Sale:
    sale_data = sale.model_dump(
        exclude={"sale_items", "reference_no", "expected_currency_id", "expected_total"},
        exclude_none=True,
    )
    invoice_no = (sale_data.get("invoice_no") or "").strip()
    sale_data["invoice_no"] = invoice_no or generate_invoice_no(session)
    db_sale = Sale.model_validate(sale_data)
    if settlement_currency is not None:
        db_sale.currency_code = settlement_currency.code
        db_sale.currency_symbol = settlement_currency.symbol
    session.add(db_sale)
    session.flush()
    items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items, settlement_currency)
    db_sale.sale_items.extend(items)
    _set_sale_totals(db_sale)
    return db_sale


def create_sale(session: Session, sale: SaleCreate):
    try:
        db_sale = _add_sale(session, sale)
        session.commit()
    except Exception:
        session.rollback()
        raise

    return get_sale(session, db_sale.id)


def create_sale_checkout(session: Session, checkout: SaleCheckoutCreate):
    """Save a fully paid sale, its payment, and stock changes atomically."""
    try:
        db_sale = _add_sale(session, checkout)
        if db_sale.total_amount <= 0:
            raise HTTPException(status_code=400, detail="Sale total must be positive.")
        session.add(SalePayment(
            user_id=checkout.user_id,
            sale_id=db_sale.id,
            amount=db_sale.total_amount,
            payment_method=checkout.payment_method,
            reference_no=checkout.reference_no,
            payment_date=checkout.sale_date,
            note="Sale payment",
            created_at=checkout.sale_date,
        ))
        db_sale.paid_amount = db_sale.total_amount
        _set_sale_totals(db_sale)
        session.add(db_sale)
        result = {
            "id": db_sale.id,
            "subtotal": db_sale.subtotal,
            "total_amount": db_sale.total_amount,
        }
        session.commit()
        return result
    except Exception:
        session.rollback()
        raise


def create_converted_sale_checkout(session: Session, checkout: ConvertedSaleCheckoutCreate):
    """Recheck the confirmed total and atomically save the converted sale."""
    try:
        target = _sale_currency(session, checkout.user_id)
        if target.id != checkout.expected_currency_id:
            raise HTTPException(status_code=409, detail="The sale currency changed. Refresh and review the total.")
        db_sale = _add_sale(session, checkout, target)
        if db_sale.total_amount != checkout.expected_total:
            raise HTTPException(status_code=409, detail="Prices or exchange rates changed. Refresh and review the total.")
        if db_sale.total_amount <= 0:
            raise HTTPException(status_code=400, detail="Sale total must be positive.")
        session.add(SalePayment(
            user_id=checkout.user_id, sale_id=db_sale.id,
            amount=db_sale.total_amount, payment_method=checkout.payment_method,
            reference_no=checkout.reference_no, payment_date=checkout.sale_date,
            note="Sale payment", created_at=checkout.sale_date,
        ))
        db_sale.paid_amount = db_sale.total_amount
        _set_sale_totals(db_sale)
        session.add(db_sale)
        result = {"id": db_sale.id, "subtotal": db_sale.subtotal,
                  "total_amount": db_sale.total_amount,
                  "currency_code": target.code, "currency_symbol": target.symbol}
        session.commit()
        return result
    except Exception:
        session.rollback()
        raise

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
    statement = select(Sale).where(Sale.id == sale_id).options(selectinload(Sale.sale_items))
    db_sale = session.exec(statement).first()
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
            for old_item in db_sale.sale_items:
                _restore_warehouse_stock(
                    session, old_item.product_id, old_item.qty
                )

            items, db_sale.subtotal = _build_sale_items(session, db_sale.id, sale.sale_items)
            for old_item in db_sale.sale_items:
                session.delete(old_item)
            db_sale.sale_items = items

        _set_sale_totals(db_sale)

        db_sale.updated_at = sale.updated_at or datetime.now(timezone.utc)
        session.add(db_sale)
        session.commit()
    except Exception:
        session.rollback()
        raise

    return get_sale(session, sale_id)

def delete_sale(session: Session, sale_id: int):

    sale = session.get(Sale, sale_id)

    if not sale:
        return None

    try:
        # Put the sold quantities back into warehouse stock.
        for item in sale.sale_items:
            _restore_warehouse_stock(session, item.product_id, item.qty)

        # delete sale items first
        for item in sale.sale_items:
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
