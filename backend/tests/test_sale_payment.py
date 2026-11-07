from datetime import datetime, timezone
from decimal import Decimal

import pytest
from fastapi import HTTPException
from sqlmodel import select

from app.crud.sale.sale_payment import (
    create_sale_payment,
    delete_sale_payment,
    update_sale_payment,
)
from app.models.customer import Customer
from app.models.role import Role
from app.models.sale import Sale
from app.models.sale_payment import SalePayment
from app.models.user import User
from app.schemas.sale.sale_payment import SalePaymentCreate, SalePaymentUpdate


def make_sale(session, total="100.00"):
    role = Role(name="Cashier")
    session.add(role)
    session.commit()
    session.refresh(role)

    user = User(
        name="Cashier",
        email="cashier@example.com",
        password="x",
        role_id=role.id,
        phone=None,
        photo=None,
        is_active=True,
    )
    customer = Customer(name="Walk-in")
    session.add_all([user, customer])
    session.commit()
    session.refresh(user)
    session.refresh(customer)

    sale = Sale(
        user_id=user.id,
        customer_id=customer.id,
        invoice_no="SALE-1",
        sale_date=datetime.now(timezone.utc),
        subtotal=Decimal(total),
        tax_amount=Decimal("0.00"),
        discount_amount=Decimal("0.00"),
        total_amount=Decimal(total),
        paid_amount=Decimal("0.00"),
        due_amount=Decimal(total),
        payment_status="unpaid",
        status="completed",
        payment_method="Cash",
    )
    session.add(sale)
    session.commit()
    session.refresh(sale)
    return sale


def payment(sale_id, amount, user_id):
    return SalePaymentCreate(
        user_id=user_id,
        sale_id=sale_id,
        amount=Decimal(amount),
        payment_method="Cash",
        reference_no="SP-1",
        payment_date=datetime.now(timezone.utc),
        note="",
        created_at=datetime.now(timezone.utc),
    )


def test_create_payment_updates_sale_totals(session):
    sale = make_sale(session)

    create_sale_payment(session, payment(sale.id, "40.00", sale.user_id))

    assert sale.paid_amount == Decimal("40.00")
    assert sale.due_amount == Decimal("60.00")
    assert sale.payment_status == "partial"


def test_second_payment_marks_sale_paid_and_clamps_due(session):
    sale = make_sale(session)

    create_sale_payment(session, payment(sale.id, "60.00", sale.user_id))
    create_sale_payment(session, payment(sale.id, "50.00", sale.user_id))

    assert sale.paid_amount == Decimal("110.00")
    assert sale.due_amount == Decimal("0.00")
    assert sale.payment_status == "paid"


def test_update_payment_sale_recalculates(session):
    sale = make_sale(session)
    created = create_sale_payment(session, payment(sale.id, "40.00", sale.user_id))

    update_sale_payment(session, created.id, SalePaymentUpdate(amount=Decimal("70.00")))

    assert sale.paid_amount == Decimal("70.00")
    assert sale.due_amount == Decimal("30.00")
    assert sale.payment_status == "partial"


def test_moving_payment_recalculates_both_sales(session):
    first = make_sale(session)
    second = make_sale(session)
    created = create_sale_payment(session, payment(first.id, "40.00", first.user_id))

    update_sale_payment(session, created.id, SalePaymentUpdate(sale_id=second.id))

    assert first.paid_amount == Decimal("0.00")
    assert first.payment_status == "unpaid"
    assert second.paid_amount == Decimal("40.00")
    assert second.payment_status == "partial"


def test_delete_payment_recalculates_sale(session):
    sale = make_sale(session)
    session.add(
        SalePayment(
            user_id=sale.user_id,
            sale_id=sale.id,
            amount=Decimal("100.00"),
            payment_method="Cash",
            reference_no="SP-1",
            payment_date=datetime.now(timezone.utc),
            note="",
        )
    )
    sale.paid_amount = Decimal("100.00")
    sale.due_amount = Decimal("0.00")
    sale.payment_status = "paid"
    session.add(sale)
    session.commit()
    [created] = session.exec(select(SalePayment)).all()

    delete_sale_payment(session, created.id)

    assert sale.paid_amount == Decimal("0.00")
    assert sale.due_amount == Decimal("100.00")
    assert sale.payment_status == "unpaid"


def test_payment_for_missing_sale_is_rejected(session):
    sale = make_sale(session)

    with pytest.raises(HTTPException) as exc:
        create_sale_payment(session, payment(999, "10.00", sale.user_id))

    assert exc.value.status_code == 404
    assert session.exec(select(SalePayment)).all() == []

import asyncio

from app.routes.sale import sale_payment as sale_payment_routes


def test_payment_routes_clear_sale_cache(session, monkeypatch):
    sale = make_sale(session)
    cleared = []

    async def fake_clear(namespace=None):
        cleared.append(namespace)

    monkeypatch.setattr(sale_payment_routes.FastAPICache, "clear", fake_clear)

    created = asyncio.run(
        sale_payment_routes.create_new_sale(
            payment(sale.id, "10.00", sale.user_id), session
        )
    )
    asyncio.run(
        sale_payment_routes.update_sale_payment_route(
            created.id, SalePaymentUpdate(amount=Decimal("20.00")), session
        )
    )
    asyncio.run(sale_payment_routes.delete_sale_payment_route(created.id, session))

    assert cleared == ["sale", "sale", "sale"]
