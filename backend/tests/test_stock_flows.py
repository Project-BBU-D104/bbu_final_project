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


from app.crud.purchase.purchase import create_purchase
from app.crud.purchase.purchase_payment import create_purchase_payment
from app.models.payment_type import PaymentType
from app.models.supplier import Supplier
from app.schemas.purchase.purchase import PurchaseCreate
from app.schemas.purchase.purchase_item import PurchaseItemCreate
from app.schemas.purchase.purchase_payment import PurchasePaymentCreate


def make_supplier(session):
    supplier = Supplier(
        name="Dara", phone="012345678", email="dara@example.com",
        map="", address="Phnom Penh", status=True,
    )
    session.add(supplier)
    session.commit()
    session.refresh(supplier)
    return supplier


def make_purchase(session, seed, user, supplier, product, qty, total="100.00"):
    return create_purchase(session, PurchaseCreate(
        user_id=user.id, supplier_id=supplier.id,
        warehouse_id=seed["warehouse_a"].id,
        purchase_date=datetime.now(timezone.utc),
        subtotal=Decimal(total), tax_amount=Decimal("0.00"),
        discount_amount=Decimal("0.00"), total_amount=Decimal(total),
        paid_amount=Decimal("0.00"), due_amount=Decimal(total),
        items=[PurchaseItemCreate(
            product_id=product.id, cost_price=Decimal("1.00"),
            qty=Decimal(qty), subtotal=Decimal(qty),
        )],
    ))


def make_payment_type(session):
    payment_type = PaymentType(name="Bank")
    session.add(payment_type)
    session.commit()
    session.refresh(payment_type)
    return payment_type


def test_purchase_increases_warehouse_stock(session, seed):
    user, supplier = make_user(session), make_supplier(session)
    product = make_stocked_product(session, seed, qty=0)

    make_purchase(session, seed, user, supplier, product, qty=5)

    assert stock_qty(session, product.id, seed["warehouse_a"].id) == 5


def test_purchase_payment_updates_paid_due_status(session, seed):
    user, supplier = make_user(session), make_supplier(session)
    product = make_stocked_product(session, seed, qty=0)
    purchase = make_purchase(session, seed, user, supplier, product, qty=5)
    payment_type = make_payment_type(session)

    create_purchase_payment(session, PurchasePaymentCreate(
        payment_no="PP-1", purchase_id=purchase.id, supplier_id=supplier.id,
        payment_type_id=payment_type.id, currency_id=seed["currency"].id,
        amount=40.0, payment_date=datetime.now(timezone.utc),
    ))

    session.refresh(purchase)
    assert purchase.paid_amount == Decimal("40.00")
    assert purchase.due_amount == Decimal("60.00")
    assert purchase.payment_status == "partial"


def test_pending_purchase_payment_does_not_count(session, seed):
    user, supplier = make_user(session), make_supplier(session)
    product = make_stocked_product(session, seed, qty=0)
    purchase = make_purchase(session, seed, user, supplier, product, qty=5)
    payment_type = make_payment_type(session)

    create_purchase_payment(session, PurchasePaymentCreate(
        payment_no="PP-2", purchase_id=purchase.id, supplier_id=supplier.id,
        payment_type_id=payment_type.id, currency_id=seed["currency"].id,
        amount=40.0, payment_date=datetime.now(timezone.utc), status="pending",
    ))

    session.refresh(purchase)
    assert purchase.paid_amount == Decimal("0.00")
    assert purchase.due_amount == Decimal("100.00")
    assert purchase.payment_status == "unpaid"