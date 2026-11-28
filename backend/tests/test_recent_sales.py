from datetime import datetime, timezone
from decimal import Decimal

from app.models.sale import Sale
from app.models.sale_items import SaleItems
from app.routes.home import home
from test_stock_flows import make_customer, make_stocked_product, make_user


def test_recent_sales_returns_five_orders_not_five_items(session, seed, monkeypatch):
    user, customer = make_user(session), make_customer(session)
    product = make_stocked_product(session, seed, qty=20)
    sales = []
    for index in range(6):
        sale = Sale(
            user_id=user.id,
            customer_id=customer.id,
            invoice_no="SAME-INVOICE" if index >= 4 else f"SALE-{index}",
            sale_date=datetime.now(timezone.utc),
            subtotal=Decimal("100.00"),
            tax_amount=Decimal("5.00"),
            discount_amount=Decimal("0.00"),
            total_amount=Decimal("105.00"),
            paid_amount=Decimal("105.00"),
            due_amount=Decimal("0.00"),
            payment_status="paid",
            status="completed",
            payment_method="Cash",
            currency_code="KHR" if index == 5 else None,
            currency_symbol="៛" if index == 5 else None,
        )
        session.add(sale)
        session.flush()
        sales.append(sale)
    for _ in range(4):
        session.add(SaleItems(
            sale_id=sales[-1].id,
            product_id=product.id,
            qty=1,
            sale_price=Decimal("25.00"),
            subtotal=Decimal("25.00"),
        ))
    session.commit()
    monkeypatch.setattr(home, "engine", session.get_bind())

    recent = home.get_recent_sales()

    assert [row["sale_id"] for row in recent] == [sale.id for sale in reversed(sales[1:])]
    assert recent[0]["invoice_no"] == recent[1]["invoice_no"] == "SAME-INVOICE"
    assert Decimal(str(recent[0]["total_amount"])) == Decimal("105.00")
    assert Decimal(str(recent[0]["subtotal"])) == Decimal("100.00")
    assert recent[0]["currency_code"] == "KHR"
    assert recent[0]["currency_symbol"] == "៛"
    assert recent[1]["currency_code"] is None
