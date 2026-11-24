import os
from concurrent.futures import ThreadPoolExecutor
from threading import Barrier
from uuid import uuid4

import pytest
from fastapi import HTTPException
from sqlmodel import Session, create_engine, select

from app.crud.sale.checkout import checkout_sale
from app.models import (Category, Checkout, Currency, Customer, PaymentType, Product, Role,
                        Sale, SaleItems, SalePayment, Unit, User, Warehouse, WarehouseStock)
from app.schemas.sale.checkout import CheckoutCreate

URL = os.getenv("CHECKOUT_TEST_DATABASE_URL")
pytestmark = pytest.mark.skipif(not URL, reason="Requires a disposable migrated MySQL database")


@pytest.mark.parametrize("same_key,quantity,expected", [(True, 3, 1), (False, 3, 1), (False, 6, 2)])
def test_simultaneous_checkout(same_key, quantity, expected):
    engine = create_engine(URL)
    token = uuid4().hex
    with Session(engine, expire_on_commit=False) as setup:
        category = Category(name=token)
        unit = Unit(name=token, short_name="pc")
        currency = Currency(name=token, code=token[:3], symbol="$", exchange_rate=1)
        warehouse = Warehouse(name=token, reference_no=token, location="A", note="")
        role = Role(name=token)
        customer = Customer(name=token)
        method = PaymentType(name=token)
        setup.add_all([category, unit, currency, warehouse, role, customer, method])
        setup.flush()
        user = User(name=token, email=f"{token}@example.com", password="x", role_id=role.id)
        product = Product(name=token, barcode=token, photo="", category_id=category.id,
                          unit_id=unit.id, currency_id=currency.id, cost_price=1, sale_price=2)
        setup.add_all([user, product])
        setup.flush()
        stock = WarehouseStock(product_id=product.id, warehouse_id=warehouse.id, qty=quantity)
        setup.add(stock)
        setup.commit()
        request = CheckoutCreate(checkout_id=token, customer_id=customer.id,
                                 payment_type_id=method.id, expected_total="6.00",
                                 sale_items=[dict(product_id=product.id, warehouse_id=warehouse.id, qty=3)])
        second = request if same_key else request.model_copy(update={"checkout_id": uuid4().hex})
        barrier = Barrier(2)

        def submit(body):
            with Session(engine) as session:
                session.connection()
                barrier.wait(timeout=10)
                try:
                    return checkout_sale(session, body, user.id)
                except HTTPException as error:
                    assert error.status_code == 400 and "Only 0 left" in error.detail
                    return None

        try:
            with ThreadPoolExecutor(max_workers=2) as pool:
                receipts = list(pool.map(submit, [request, second]))
            if same_key:
                assert receipts[0] == receipts[1] and receipts[0] is not None
            else:
                assert sum(r is not None for r in receipts) == expected
            assert len({r.invoice_no for r in receipts if r}) == expected
            assert len(setup.exec(select(SalePayment).where(SalePayment.user_id == user.id)).all()) == expected
            setup.refresh(stock)
            assert stock.qty == quantity - 3 * expected
        finally:
            sales = setup.exec(select(Sale).where(Sale.user_id == user.id)).all()
            for sale in sales:
                for row in [*sale.sale_payments, *sale.sale_items]:
                    setup.delete(row)
                setup.flush()
                setup.delete(sale)
            for key in {token, second.checkout_id}:
                claim = setup.get(Checkout, key)
                if claim:
                    setup.delete(claim)
            setup.delete(stock)
            setup.flush()
            for row in (user, product, customer, method):
                setup.delete(row)
            setup.flush()
            for row in (warehouse, role, category, unit, currency):
                setup.delete(row)
            setup.commit()
    engine.dispose()
