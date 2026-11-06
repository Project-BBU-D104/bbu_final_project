from datetime import datetime, timezone
from decimal import Decimal

from app.crud.sale.sale import get_all_sales
from app.models.customer import Customer
from app.models.product import Product
from app.models.role import Role
from app.models.sale import Sale
from app.models.sale_items import SaleItems
from app.models.user import User
from app.schemas.sale.sale import SaleRead


def test_sale_items_include_product_unit(session, seed):
    role = Role(name="Admin")
    session.add(role)
    session.commit()
    session.refresh(role)

    user = User(
        name="cashier",
        email="cashier",
        password="x",
        role_id=role.id,
        phone="",
        photo="",
        is_active=True,
    )
    customer = Customer(name="Walk-in", phone="")
    product = Product(
        category_id=seed["category"].id,
        unit_id=seed["unit"].id,
        currency_id=seed["currency"].id,
        name="Helmet",
        barcode="helmet",
        photo="",
        cost_price=Decimal("10.00"),
        sale_price=Decimal("20.00"),
    )
    session.add_all([user, customer, product])
    session.commit()
    for row in (user, customer, product):
        session.refresh(row)

    sale = Sale(
        user_id=user.id,
        customer_id=customer.id,
        invoice_no="SALE-1",
        sale_date=datetime.now(timezone.utc),
        subtotal=Decimal("60.00"),
        tax_amount=Decimal("0.00"),
        discount_amount=Decimal("0.00"),
        total_amount=Decimal("60.00"),
        paid_amount=Decimal("60.00"),
        due_amount=Decimal("0.00"),
        payment_status="paid",
        status="completed",
        payment_method="Cash",
    )
    session.add(sale)
    session.commit()
    session.refresh(sale)

    session.add(
        SaleItems(
            sale_id=sale.id,
            product_id=product.id,
            qty=3,
            sale_price=Decimal("20.00"),
            subtotal=Decimal("60.00"),
        )
    )
    session.commit()

    [sale_row] = get_all_sales(session)
    payload = SaleRead.model_validate(sale_row).model_dump(mode="json")

    assert payload["sale_items"][0]["product"]["unit"]["short_name"] == "pc"