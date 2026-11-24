from decimal import Decimal
from unittest.mock import AsyncMock

import pytest
from fastapi import HTTPException

from fastapi_cache import FastAPICache
from sqlalchemy import event
from sqlmodel import Session, select

from app.crud.sale.checkout import checkout_sale
from app.crud.sale.sale import delete_sale
from app.models import Checkout, Product, Sale, SaleItems, SalePayment, User, WarehouseStock, PaymentType
from app.schemas.sale.checkout import CheckoutCreate
from app.security import get_current_user
from database import get_session
from main import app
from test_stock_flows import make_user, make_customer, make_payment_type, make_stocked_product, stock_qty


@pytest.fixture
def purchase(session, seed):
    user = make_user(session)
    customer = make_customer(session)
    method = make_payment_type(session)
    product = make_stocked_product(session, seed, 1)
    a, b = seed["warehouse_a"].id, seed["warehouse_b"].id
    session.add(WarehouseStock(product_id=product.id, warehouse_id=b, qty=3))
    session.commit()
    request = CheckoutCreate(checkout_id="a"*32, customer_id=customer.id,
                             payment_type_id=method.id, expected_total="6.00",
                             sale_items=[dict(product_id=product.id, warehouse_id=b, qty=3)])
    return request, user.id, product.id, a, b


def counts(session):
    return [len(session.exec(select(model)).all())
            for model in (Checkout, Sale, SaleItems, SalePayment)]


def test_lost_response_replays_original_receipt(session, purchase):
    request, user, product, a, b = purchase
    engine = session.get_bind()
    receipt = checkout_sale(session, request, user)
    session.close()
    with Session(engine) as fresh:
        fresh.get(Product, product).name = "Renamed"
        fresh.commit()
    with Session(engine) as fresh:
        assert checkout_sale(fresh, request, user) == receipt
        assert receipt.total == Decimal("6.00")
        line, = receipt.lines
        assert (line.product_name, line.warehouse_id, line.qty, line.subtotal) == ("Coke", b, 3, receipt.total)
        assert counts(fresh) == [1]*4
        sale = fresh.exec(select(Sale)).one()
        assert (sale.payment_status, sale.due_amount) == ("paid", 0)
        assert receipt.invoice_no == f"POS-{sale.id}"
        assert fresh.exec(select(SalePayment)).one().amount == receipt.total
        assert (stock_qty(fresh, product, a), stock_qty(fresh, product, b)) == (1, 0)
        delete_sale(fresh, sale.id)
        assert checkout_sale(fresh, request, user) == receipt
        assert stock_qty(fresh, product, b) == 3


def test_payment_failure_rolls_back_entire_checkout(session, purchase):
    request, user, product, _, b = purchase

    def fail(*args):
        raise RuntimeError("payment insert failed")

    event.listen(SalePayment, "before_insert", fail)
    try:
        with pytest.raises(RuntimeError, match="payment insert failed"):
            checkout_sale(session, request, user)
    finally:
        event.remove(SalePayment, "before_insert", fail)
    with Session(session.get_bind()) as fresh:
        assert counts(fresh) == [0]*4
        assert stock_qty(fresh, product, b) == 3
        assert checkout_sale(fresh, request, user).total == Decimal("6.00")


@pytest.mark.parametrize("change", ["quantity", "method", "cashier"])
def test_checkout_id_conflict(session, purchase, change):
    request, user, *_ = purchase
    checkout_sale(session, request, user)
    if change == "quantity":
        request.sale_items[0].qty -= 1
    elif change == "method":
        request.payment_type_id += 1
    else:
        user += 1
    with pytest.raises(HTTPException) as err:
        checkout_sale(session, request, user)
    assert err.value.status_code == 409 and "POS-" not in err.value.detail
    assert counts(session) == [1]*4


@pytest.mark.parametrize("change", ["inactive", "customer", "price", "shortage", "product"])
def test_business_rejection(session, purchase, change):
    request, user, product, a, b = purchase
    if change == "inactive":
        session.get(PaymentType, request.payment_type_id).status = False
        session.commit()
    elif change == "customer":
        request.customer_id += 20
    elif change == "price":
        request.expected_total += 1
    elif change == "product":
        request.sale_items[0].product_id += 20
    else:
        request.sale_items.insert(0, request.sale_items[0].model_copy(update={"warehouse_id": a, "qty": 1}))
        request.sale_items[1].qty = 4
    with pytest.raises(HTTPException) as err:
        checkout_sale(session, request, user)
    assert err.value.status_code == 400
    if change == "shortage":
        assert all(x in err.value.detail for x in ("Coke", "3", "4"))
    assert counts(session) == [0]*4
    assert (stock_qty(session, product, a), stock_qty(session, product, b)) == (1, 3)


def test_registered_checkout(session, purchase, monkeypatch):
    request, user, *_ = purchase
    from fastapi.testclient import TestClient
    client = TestClient(app)
    url = "/sale/checkout/"
    body = request.model_dump(mode="json")
    monkeypatch.setitem(app.dependency_overrides, get_session, lambda: session)
    assert client.post(url, json=body).status_code in (401, 403)
    monkeypatch.setitem(app.dependency_overrides, get_current_user, lambda: session.get(User, user))
    clear = AsyncMock()
    monkeypatch.setattr(FastAPICache, "clear", clear)
    for invalid in ({"expected_total": "0"}, {"user_id": user}, {"sale_items": body["sale_items"] * 2}):
        assert client.post(url, json=body | invalid).status_code == 422
    for _ in range(2):
        response = client.post(url, json=body)
        assert response.status_code == 200
        assert response.json()["total"] == "6.00"
    assert [c.kwargs["namespace"] for c in clear.await_args_list] == ["sale", "warehouse", "product"] * 2
