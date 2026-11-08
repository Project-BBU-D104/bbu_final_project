from datetime import datetime, timezone
from decimal import Decimal

from app.crud.sale.sale_payment import create_sale_payment
from app.models.customer import Customer
from app.models.role import Role
from app.models.sale import Sale
from app.models.user import User
from app.schemas.purchase.purchase_payment import PurchasePaymentRead
from app.schemas.sale.sale_payment import SalePaymentCreate, SalePaymentRead


def make_sale(session, total="10.00"):
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
    customer = Customer(name="Walk-in", phone="010000000")
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


def test_read_schemas_expose_id_model_field():
    assert "id" in SalePaymentRead.model_fields
    assert "id" in PurchasePaymentRead.model_fields


def test_created_sale_payment_validates_with_orm_id(session):
    sale = make_sale(session)
    created = create_sale_payment(
        session,
        SalePaymentCreate(
            user_id=sale.user_id,
            sale_id=sale.id,
            amount=Decimal("8.00"),
            payment_method="Cash",
            reference_no="REF-1",
            payment_date=datetime.now(timezone.utc),
            note="Deposit",
            created_at=datetime.now(timezone.utc),
        ),
    )

    read = SalePaymentRead.model_validate(created)

    assert read.id == created.id
