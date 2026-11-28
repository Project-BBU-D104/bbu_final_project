from decimal import Decimal

import pytest
from fastapi import HTTPException
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlmodel import select

from app.crud.sale.sale import create_converted_sale_checkout
from app.models.currency import Currency
from app.models.sale import Sale
from app.models.sale_payment import SalePayment
from app.models.system_configuration import SystemConfiguration
from app.schemas.sale.sale import ConvertedSaleCheckoutCreate
from app.schemas.sale.sale_item import SaleItemCreate
from test_stock_flows import make_customer, make_stocked_product, make_user, sale_payload, stock_qty


def configured_sale(session, seed, target_code="KHR"):
    user, customer = make_user(session), make_customer(session)
    usd = seed["currency"]
    usd.is_default = target_code != "USD"  # The configuration, not this flag, wins.
    riel = Currency(name="Riel", code="KHR", symbol="៛", exchange_rate=4000)
    session.add_all([usd, riel])
    session.flush()
    target = riel if target_code == "KHR" else usd
    config = SystemConfiguration(company_name="Shop", default_currency_id=target.id)
    session.add(config)
    session.flush()
    user.system_configuration_id = config.id
    session.add(user)
    session.commit()
    return user, customer, usd, riel, target


def checkout_for(user, customer, items, target, expected):
    first = items[0][0]
    base = sale_payload(user.id, customer.id, first.id, items[0][1]).model_dump()
    base["sale_items"] = [SaleItemCreate(product_id=p.id, qty=q) for p, q in items]
    return ConvertedSaleCheckoutCreate(
        **base, reference_no="PAY-1", expected_currency_id=target.id,
        expected_total=Decimal(expected),
    )


def test_converts_to_configured_currency_and_saves_payment(session, seed):
    user, customer, usd, riel, target = configured_sale(session, seed)
    kuromi = make_stocked_product(session, seed, 10, "Kuromi", "kuromi")
    books = make_stocked_product(session, seed, 10, "Books", "books")
    moto = make_stocked_product(session, seed, 10, "Motorcycle", "moto")
    kuromi.sale_price = Decimal("6")
    books.sale_price = Decimal("1")
    moto.sale_price, moto.currency_id = Decimal("30"), riel.id
    session.add_all([kuromi, books, moto])
    session.commit()

    result = create_converted_sale_checkout(
        session, checkout_for(user, customer, [(kuromi, 2), (books, 1), (moto, 1)], target, "52030")
    )
    sale = session.get(Sale, result["id"])
    payment = session.exec(select(SalePayment)).one()
    assert result["total_amount"] == Decimal("52030")
    assert sale.currency_code == "KHR" and sale.currency_symbol == "៛"
    assert payment.amount == Decimal("52030")
    assert [item.sale_price for item in sale.sale_items] == [Decimal("24000"), Decimal("4000"), Decimal("30")]


def test_changed_exchange_rate_rejects_and_restores_stock(session, seed):
    user, customer, usd, riel, target = configured_sale(session, seed)
    product = make_stocked_product(session, seed, 10)
    request = checkout_for(user, customer, [(product, 2)], target, "16000")
    riel.exchange_rate = 4100
    session.add(riel)
    session.commit()
    with pytest.raises(HTTPException) as error:
        create_converted_sale_checkout(session, request)
    assert error.value.status_code == 409
    assert session.exec(select(Sale)).all() == []
    assert session.exec(select(SalePayment)).all() == []
    assert stock_qty(session, product.id, seed["warehouse_a"].id) == 10


def test_converts_riel_to_dollars_with_half_up_line_rounding(session, seed):
    user, customer, usd, riel, target = configured_sale(session, seed, "USD")
    product = make_stocked_product(session, seed, 10)
    product.currency_id, product.sale_price = riel.id, Decimal("100")
    session.add(product)
    session.commit()
    result = create_converted_sale_checkout(
        session, checkout_for(user, customer, [(product, 2)], target, "0.05")
    )
    assert result["total_amount"] == Decimal("0.05")
    item = session.get(Sale, result["id"]).sale_items[0]
    assert item.original_unit_price == Decimal("100")
    assert item.original_currency_code == "KHR"
    assert item.subtotal == Decimal("0.05")


def test_missing_or_invalid_exchange_rate_does_not_create_sale(session, seed):
    user, customer, usd, riel, target = configured_sale(session, seed)
    product = make_stocked_product(session, seed, 10)
    usd.exchange_rate = 0
    session.add(usd)
    session.commit()
    with pytest.raises(HTTPException) as error:
        create_converted_sale_checkout(session, checkout_for(user, customer, [(product, 1)], target, "8000"))
    assert error.value.status_code == 400
    assert session.exec(select(Sale)).all() == []
    assert stock_qty(session, product.id, seed["warehouse_a"].id) == 10


def test_converted_checkout_endpoint_requires_matching_signed_in_user(session, seed, monkeypatch):
    from app.routes.sale import sale as sale_routes
    from app.security import get_current_user
    from database import get_session

    user, customer, usd, riel, target = configured_sale(session, seed)
    product = make_stocked_product(session, seed, 10)
    request = checkout_for(user, customer, [(product, 1)], target, "8000")
    app = FastAPI()
    app.include_router(sale_routes.router)
    app.dependency_overrides[get_session] = lambda: session
    app.dependency_overrides[get_current_user] = lambda: user

    async def clear_caches():
        pass

    monkeypatch.setattr(sale_routes, "_clear_sale_caches", clear_caches)
    with TestClient(app) as client:
        payload = request.model_dump(mode="json")
        wrong_user = {**payload, "user_id": user.id + 1}
        assert client.post("/sale/checkout-converted/", json=wrong_user).status_code == 403
        response = client.post("/sale/checkout-converted/", json=payload)
    assert response.status_code == 200, response.text
    assert response.json()["currency_code"] == "KHR"
    assert Decimal(str(response.json()["total_amount"])) == Decimal("8000")
