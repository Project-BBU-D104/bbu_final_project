from app.core.cache import ORMJsonCoder
from app.crud.warehouse.warehouse import get_all_warehouse
from app.models.product import Product
from app.models.warehouse_stock import WarehouseStock
from app.schemas.warehouse.warehouse import WarehouseRead

from fastapi import FastAPI
from fastapi.testclient import TestClient
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend

from app.core.cache import cache_key_builder
from app.routes.warehouse.warehouse import router as warehouse_router
from database import get_session


def make_product(session, seed):
    product = Product(
        category_id=seed["category"].id,
        unit_id=seed["unit"].id,
        currency_id=seed["currency"].id,
        name="Coke",
        barcode="123456",
        photo="",
    )
    session.add(product)
    session.commit()
    session.refresh(product)
    return product


def test_cached_warehouse_payload_keeps_stock(session, seed):
    product = make_product(session, seed)
    session.add(
        WarehouseStock(
            product_id=product.id,
            warehouse_id=seed["warehouse_a"].id,
            qty=5,
        )
    )
    session.commit()

    # FastAPICache encodes the endpoint's return value before FastAPI's
    # response_model runs, so relationships are not loaded yet at this point.
    raw = ORMJsonCoder.encode(get_all_warehouse(session))
    decoded = ORMJsonCoder.decode(raw)

    warehouse = next(row for row in decoded if row["id"] == seed["warehouse_a"].id)
    read = WarehouseRead.model_validate(warehouse)

    assert len(read.warehouse_stock) == 1
    assert read.warehouse_stock[0].qty == 5
    assert read.warehouse_stock[0].product.name == "Coke"


def test_warehouse_endpoint_returns_stock_on_cache_hit(session, seed):
    product = make_product(session, seed)
    session.add(
        WarehouseStock(
            product_id=product.id,
            warehouse_id=seed["warehouse_a"].id,
            qty=5,
        )
    )
    session.commit()

    FastAPICache.init(
        InMemoryBackend(),
        prefix="test-cache",
        key_builder=cache_key_builder,
        coder=ORMJsonCoder,
        expire=60,
    )

    app = FastAPI()
    app.include_router(warehouse_router)
    app.dependency_overrides[get_session] = lambda: session

    with TestClient(app) as client:
        first = client.get("/warehouse/")
        second = client.get("/warehouse/")

    assert first.status_code == 200, first.text
    assert second.status_code == 200, second.text

    # The second response comes from FastAPICache; it must still contain stock.
    for response in (first, second):
        warehouse = next(
            row
            for row in response.json()
            if row["id"] == seed["warehouse_a"].id
        )
        assert len(warehouse["warehouse_stock"]) == 1
        assert warehouse["warehouse_stock"][0]["qty"] == 5
        assert warehouse["warehouse_stock"][0]["product"]["name"] == "Coke"

