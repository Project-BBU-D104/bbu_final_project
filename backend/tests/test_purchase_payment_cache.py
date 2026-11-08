import asyncio
from datetime import datetime, timezone

import pytest

from app.routes.purchase import purchase_payment as routes
from app.schemas.purchase.purchase_payment import (
    PurchasePaymentCreate,
    PurchasePaymentUpdate,
)


class FakeSession:
    pass


@pytest.fixture
def cleared_namespaces(monkeypatch):
    calls = []

    async def fake_clear(namespace=None):
        calls.append(namespace)

    monkeypatch.setattr(routes.FastAPICache, "clear", fake_clear)
    monkeypatch.setattr(
        routes, "create_purchase_payment", lambda session, payload: payload
    )
    monkeypatch.setattr(
        routes, "update_purchase_payment", lambda session, payment_id, payload: payload
    )
    monkeypatch.setattr(
        routes, "delete_purchase_payment", lambda session, payment_id: {"ok": True}
    )
    return calls


def make_create_payload():
    return PurchasePaymentCreate(
        payment_no="PP-1",
        purchase_id=3,
        supplier_id=9,
        payment_type_id=2,
        currency_id=1,
        amount=75.0,
        payment_date=datetime.now(timezone.utc),
        status="completed",
        note="Deposit",
    )


def test_create_clears_purchase_payment_and_purchase_namespaces(cleared_namespaces):
    asyncio.run(
        routes.create_new_purchase_payment(make_create_payload(), FakeSession())
    )

    assert cleared_namespaces == ["purchase_payment", "purchase"]


def test_update_clears_purchase_payment_and_purchase_namespaces(cleared_namespaces):
    asyncio.run(
        routes.update_purchase_payment_route(
            11, PurchasePaymentUpdate(amount=75.0), FakeSession()
        )
    )

    assert cleared_namespaces == ["purchase_payment", "purchase"]


def test_delete_clears_purchase_payment_and_purchase_namespaces(cleared_namespaces):
    asyncio.run(routes.delete_purchase_payment_route(11, FakeSession()))

    assert cleared_namespaces == ["purchase_payment", "purchase"]
