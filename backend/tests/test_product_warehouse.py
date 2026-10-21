from decimal import Decimal

import pytest
from fastapi import HTTPException
from sqlmodel import select

from app.crud.product.product import create_product, get_product, update_product
from app.models.warehouse_stock import WarehouseStock
from app.schemas.product.product import ProductCreate, ProductRead, ProductUpdate


def make_product(seed, **overrides):
    data = {
        "category_id": seed["category"].id,
        "unit_id": seed["unit"].id,
        "currency_id": seed["currency"].id,
        "name": "Coke",
        "barcode": "123456",
        "photo": "",
        "cost_price": Decimal("1.00"),
        "sale_price": Decimal("2.00"),
    }
    data.update(overrides)
    return ProductCreate(**data)


def stocks_of(session, product_id):
    return session.exec(
        select(WarehouseStock).where(WarehouseStock.product_id == product_id)
    ).all()


def test_create_product_with_warehouse_creates_zero_qty_stock(session, seed):
    product = create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )

    stocks = stocks_of(session, product.id)

    assert len(stocks) == 1
    assert stocks[0].warehouse_id == seed["warehouse_a"].id
    assert stocks[0].qty == 0


def test_create_product_without_warehouse_creates_no_stock(session, seed):
    product = create_product(session, make_product(seed))

    assert stocks_of(session, product.id) == []


def test_create_product_with_unknown_warehouse_is_rejected(session, seed):
    with pytest.raises(HTTPException) as error:
        create_product(session, make_product(seed, warehouse_id=9999))

    assert error.value.status_code == 404
    assert stocks_of(session, 1) == []


def test_update_product_moves_existing_stock_and_keeps_qty(session, seed):
    product = create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )
    stock = stocks_of(session, product.id)[0]
    stock.qty = 7
    session.add(stock)
    session.commit()

    update_product(
        session,
        product.id,
        ProductUpdate(warehouse_id=seed["warehouse_b"].id),
    )

    stocks = stocks_of(session, product.id)
    assert len(stocks) == 1
    assert stocks[0].warehouse_id == seed["warehouse_b"].id
    assert stocks[0].qty == 7


def test_update_product_creates_stock_when_product_has_none(session, seed):
    product = create_product(session, make_product(seed))

    update_product(
        session,
        product.id,
        ProductUpdate(warehouse_id=seed["warehouse_a"].id),
    )

    stocks = stocks_of(session, product.id)
    assert len(stocks) == 1
    assert stocks[0].warehouse_id == seed["warehouse_a"].id
    assert stocks[0].qty == 0


def test_update_product_without_warehouse_leaves_stock_untouched(session, seed):
    product = create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )

    update_product(session, product.id, ProductUpdate(name="Coke Zero"))

    stocks = stocks_of(session, product.id)
    assert len(stocks) == 1
    assert stocks[0].warehouse_id == seed["warehouse_a"].id


def test_product_read_includes_warehouse(session, seed):
    product = create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )

    read = ProductRead.model_validate(get_product(session, product.id))

    assert read.warehouse is not None
    assert read.warehouse.id == seed["warehouse_a"].id


def test_warehouse_stock_read_still_serializes_product(session, seed):
    from app.schemas.warehouse.warehouse_stock import WarehouseStockRead

    product = create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )

    read = WarehouseStockRead.model_validate(stocks_of(session, product.id)[0])

    assert read.product.name == "Coke"
    assert read.product.warehouse.id == seed["warehouse_a"].id


def test_cached_product_payload_keeps_warehouse(session, seed):
    from app.core.cache import ORMJsonCoder
    from app.crud.product.product import get_all_product

    create_product(
        session,
        make_product(seed, warehouse_id=seed["warehouse_a"].id),
    )

    raw = ORMJsonCoder.encode(get_all_product(session))
    decoded = ORMJsonCoder.decode(raw)
    read = ProductRead.model_validate(decoded[0])

    assert read.warehouse is not None
    assert read.warehouse.id == seed["warehouse_a"].id


