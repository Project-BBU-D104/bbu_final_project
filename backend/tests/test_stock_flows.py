from datetime import datetime, timezone
from decimal import Decimal

import pytest
from fastapi import HTTPException
from sqlmodel import select

from app.crud.product.product import create_product
from app.crud.sale.sale import create_sale
from app.models.customer import Customer
from app.models.sale import Sale
from app.models.role import Role
from app.models.user import User
from app.models.warehouse_stock import WarehouseStock
from app.schemas.product.product import ProductCreate
from app.schemas.sale.sale import SaleCreate
from app.schemas.sale.sale_item import SaleItemCreate


def make_user(session):
    role = Role(name="Cashier")
    session.add(role)
    session.commit()
    session.refresh(role)
    user = User(
        name="Cashier", email="cashier@example.com", password="x",
        role_id=role.id, phone=None, photo=None, is_active=True,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def make_customer(session):
    customer = Customer(name="Walk-in")
    session.add(customer)
    session.commit()
    session.refresh(customer)
    return customer


def make_stocked_product(session, seed, qty, name="Coke", barcode="123"):
    product = create_product(session, ProductCreate(
        category_id=seed["category"].id,
        unit_id=seed["unit"].id,
        currency_id=seed["currency"].id,
        name=name, barcode=barcode, photo="",
        cost_price=Decimal("1.00"), sale_price=Decimal("2.00"),
        warehouse_id=seed["warehouse_a"].id,
    ))
    stock = session.exec(
        select(WarehouseStock).where(WarehouseStock.product_id == product.id)
    ).one()
    stock.qty = qty
    session.add(stock)
    session.commit()
    return product


def stock_qty(session, product_id, warehouse_id):
    return session.exec(
        select(WarehouseStock).where(
            WarehouseStock.product_id == product_id,
            WarehouseStock.warehouse_id == warehouse_id,
        )
    ).one().qty


def sale_payload(user_id, customer_id, product_id, qty):
    return SaleCreate(
        user_id=user_id, customer_id=customer_id,
        sale_date=datetime.now(timezone.utc),
        status="completed", payment_method="Cash",
        sale_items=[SaleItemCreate(product_id=product_id, qty=qty)],
    )


def test_sale_deducts_warehouse_stock(session, seed):
    user, customer = make_user(session), make_customer(session)
    product = make_stocked_product(session, seed, qty=10)

    sale = create_sale(session, sale_payload(user.id, customer.id, product.id, 3))

    assert stock_qty(session, product.id, seed["warehouse_a"].id) == 7
    assert sale.subtotal == Decimal("6.00")          # 3 x sale_price 2.00
    assert sale.total_amount == Decimal("6.00")
    assert sale.payment_status == "unpaid"
    assert sale.invoice_no.startswith("SALE-")


def test_overselling_is_rejected_and_nothing_is_saved(session, seed):
    user, customer = make_user(session), make_customer(session)
    product = make_stocked_product(session, seed, qty=10)

    with pytest.raises(HTTPException) as error:
        create_sale(session, sale_payload(user.id, customer.id, product.id, 11))

    assert error.value.status_code == 400
    assert stock_qty(session, product.id, seed["warehouse_a"].id) == 10
    assert session.exec(select(Sale)).all() == []


def test_selling_product_with_no_stock_row_is_rejected(session, seed):
    user, customer = make_user(session), make_customer(session)
    product = create_product(session, ProductCreate(
        category_id=seed["category"].id, unit_id=seed["unit"].id,
        currency_id=seed["currency"].id, name="Ghost", barcode="999",
        photo="", cost_price=Decimal("1.00"), sale_price=Decimal("2.00"),
        # no warehouse_id -> no WarehouseStock row
    ))

    with pytest.raises(HTTPException) as error:
        create_sale(session, sale_payload(user.id, customer.id, product.id, 1))

    assert error.value.status_code == 400
    assert session.exec(select(Sale)).all() == []