from decimal import Decimal

from app.models.category import Category
from app.models.product import Product
from app.models.warehouse_stock import WarehouseStock
from app.routes.api import product_category


def make_product(seed, name, category=None):
    product = Product(
        category_id=(category or seed["category"]).id,
        unit_id=seed["unit"].id,
        currency_id=seed["currency"].id,
        name=name,
        barcode=name.lower().replace(" ", "-"),
        photo="",
        cost_price=Decimal("1.00"),
        sale_price=Decimal("2.00"),
    )
    return product


def stock_for(session, product, warehouse, qty):
    session.add(
        WarehouseStock(
            product_id=product.id,
            warehouse_id=warehouse.id,
            qty=qty,
        )
    )


def product_ids_by_category(response):
    return {
        category["id"]: [product["id"] for product in category["products"]]
        for category in response
    }


def test_sale_products_exclude_products_without_warehouse(session, seed, monkeypatch):
    assigned = make_product(seed, "Assigned Coke")
    missing = make_product(seed, "Missing Warehouse")
    session.add_all([assigned, missing])
    session.commit()
    session.refresh(assigned)
    session.refresh(missing)

    stock_for(session, assigned, seed["warehouse_a"], 5)
    session.commit()

    monkeypatch.setattr(product_category, "engine", session.get_bind())

    response = product_category.get_product_category()

    assert product_ids_by_category(response)[seed["category"].id] == [assigned.id]


def test_sale_products_include_warehouse_with_zero_quantity(
    session, seed, monkeypatch
):
    zero_qty = make_product(seed, "Zero Qty Coke")
    session.add(zero_qty)
    session.commit()
    session.refresh(zero_qty)

    stock_for(session, zero_qty, seed["warehouse_a"], 0)
    session.commit()

    monkeypatch.setattr(product_category, "engine", session.get_bind())

    response = product_category.get_product_category()

    assert product_ids_by_category(response)[seed["category"].id] == [zero_qty.id]


def test_sale_products_hide_categories_without_visible_products(
    session, seed, monkeypatch
):
    hidden_category = Category(name="Hidden Category")
    session.add(hidden_category)
    session.commit()
    session.refresh(hidden_category)

    hidden = make_product(seed, "Hidden Product", category=hidden_category)
    session.add(hidden)
    session.commit()

    monkeypatch.setattr(product_category, "engine", session.get_bind())

    response = product_category.get_product_category()

    assert hidden_category.id not in product_ids_by_category(response)


def test_sale_products_expose_total_warehouse_qty(session, seed, monkeypatch):
    product = make_product(seed, "Two Warehouse Qty")
    session.add(product)
    session.commit()
    session.refresh(product)

    stock_for(session, product, seed["warehouse_a"], 3)
    stock_for(session, product, seed["warehouse_b"], 4)
    session.commit()

    monkeypatch.setattr(product_category, "engine", session.get_bind())

    response = product_category.get_product_category()

    [sale_product] = response[0]["products"]
    assert sale_product["qty"] == 7


def test_sale_products_are_not_duplicated_across_warehouses(
    session, seed, monkeypatch
):
    product = make_product(seed, "Two Warehouse Coke")
    session.add(product)
    session.commit()
    session.refresh(product)

    stock_for(session, product, seed["warehouse_a"], 3)
    stock_for(session, product, seed["warehouse_b"], 4)
    session.commit()

    monkeypatch.setattr(product_category, "engine", session.get_bind())

    response = product_category.get_product_category()

    assert product_ids_by_category(response)[seed["category"].id] == [product.id]
