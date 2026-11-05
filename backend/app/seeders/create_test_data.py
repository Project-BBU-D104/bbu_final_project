# python -m app.seeders.create_test_data
"""
Seed data good enough to exercise every screen.

Run after create_default_data (units, currencies, warehouses, configuration)
and create_admin_user (roles, users):

    python -m app.seeders.create_test_data

Idempotent: every row is looked up by a natural key (name, barcode,
invoice_no, reference_no) before it is inserted.
"""

from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Optional

from sqlmodel import Session, select

from database import engine
from app.models import (
    Category,
    Currency,
    Customer,
    PaymentType,
    Product,
    ProductTransfer,
    ProductTransferItem,
    Purchase,
    PurchaseItem,
    PurchasePayment,
    PurchaseRequest,
    PurchaseRequestItems,
    Sale,
    SaleItems,
    SalePayment,
    StockAdjustment,
    Supplier,
    Unit,
    User,
    Warehouse,
    WarehouseStock,
)


BASE_STOCK = 120

CATEGORIES = {
    "Beverages": "Soft drinks, water, beer and energy drinks",
    "Snacks": "Chips, biscuits and instant food",
    "Personal Care": "Toothpaste, shampoo and soap",
    "Stationery": "Office and school supplies",
}

SUPPLIERS = [
    ("Angkor Beverage Co.", "012 111 222", "sales@angkorbev.example", "Phnom Penh", "St. 271, Tuol Kork"),
    ("Mekong Snack Distributor", "012 333 444", "order@mekongsnack.example", "Phnom Penh", "St. 60, Sen Sok"),
    ("Sokimex Trading", "012 555 666", "info@sokimextrade.example", "Phnom Penh", "Monivong Blvd"),
    ("Khmer Stationery Supply", "012 777 888", "hello@khmersupply.example", "Phnom Penh", "St. 143, Toul Tom Pong"),
]

CUSTOMERS = [
    ("Sok Dara", "098 111 222", "Phnom Penh"),
    ("Chan Sreyneang", "098 333 444", "Siem Reap"),
    ("Vong Vibol", "098 555 666", "Battambang"),
    ("Ly Sothea", "098 777 888", "Kampong Cham"),
]

# (name, barcode, category, unit, cost price, sale price)
PRODUCTS = [
    ("Coca-Cola 330ml", "884000001001", "Beverages", "Can", "0.35", "0.60"),
    ("Angkor Beer 330ml", "884000001002", "Beverages", "Can", "0.40", "0.70"),
    ("Sting Energy 330ml", "884000001003", "Beverages", "Bottle", "0.38", "0.65"),
    ("Water 1.5L", "884000001004", "Beverages", "Bottle", "0.25", "0.45"),
    ("Milo 300g", "884000001005", "Beverages", "Pack", "2.10", "3.20"),
    ("Lays Chips 60g", "884000001006", "Snacks", "Pack", "0.80", "1.20"),
    ("Oreo 133g", "884000001007", "Snacks", "Pack", "0.95", "1.40"),
    ("Instant Noodles", "884000001008", "Snacks", "Pack", "0.30", "0.50"),
    ("Toothpaste 100g", "884000001009", "Personal Care", "Piece", "1.10", "1.80"),
    ("Shampoo 400ml", "884000001010", "Personal Care", "Bottle", "2.50", "3.90"),
    ("Soap 100g", "884000001011", "Personal Care", "Piece", "0.45", "0.80"),
    ("A4 Paper Ream", "884000001012", "Stationery", "Pack", "3.40", "4.80"),
]

# invoice, supplier, warehouse reference, days ago, paid ratio, items [(product, qty, cost)]
PURCHASES = [
    ("PUR-2026-001", "Angkor Beverage Co.", "WH001", 40, "1",
     [("Coca-Cola 330ml", 300, "0.35"), ("Sting Energy 330ml", 240, "0.38")]),
    ("PUR-2026-002", "Mekong Snack Distributor", "WH001", 28, "0.5",
     [("Lays Chips 60g", 200, "0.80"), ("Oreo 133g", 160, "0.95"), ("Instant Noodles", 400, "0.30")]),
    ("PUR-2026-003", "Khmer Stationery Supply", "WH002", 18, "1",
     [("A4 Paper Ream", 120, "3.40"), ("Toothpaste 100g", 90, "1.10")]),
]

# invoice, customer, days ago, paid ratio, items [(product, qty, price)]
SALES = [
    ("INV-2026-001", "Sok Dara", 14, "1",
     [("Coca-Cola 330ml", 6, "0.60"), ("Lays Chips 60g", 2, "1.20")]),
    ("INV-2026-002", "Chan Sreyneang", 12, "0.4",
     [("Angkor Beer 330ml", 12, "0.70"), ("Water 1.5L", 4, "0.45")]),
    ("INV-2026-003", "Vong Vibol", 9, "1",
     [("Milo 300g", 2, "3.20"), ("Oreo 133g", 3, "1.40"), ("Sting Energy 330ml", 6, "0.65")]),
    ("INV-2026-004", "Ly Sothea", 5, "0",
     [("A4 Paper Ream", 2, "4.80")]),
    ("INV-2026-005", "Sok Dara", 2, "1",
     [("Shampoo 400ml", 1, "3.90"), ("Soap 100g", 3, "0.80")]),
]

# reference, from warehouse, to warehouse, days ago, items [(product, qty)]
TRANSFERS = [
    ("TRF-2026-001", "WH001", "WH002", 6,
     [("Coca-Cola 330ml", 40), ("Instant Noodles", 60)]),
]

# reference, warehouse, product, kind, qty, days ago
ADJUSTMENTS = [
    ("ADJ-2026-001", "WH001", "Water 1.5L", "increase", 12, 10),
    ("ADJ-2026-002", "WH001", "Lays Chips 60g", "decrease", 5, 4),
    ("ADJ-2026-003", "WH002", "A4 Paper Ream", "increase", 8, 1),
]

# request_no, warehouse, days ago, status, items [(product, unit, qty)]
PURCHASE_REQUESTS = [
    ("REQ-2026-001", "WH001", 8, "Approved",
     [("Milo 300g", "Pack", 24), ("Soap 100g", "Piece", 48)]),
    ("REQ-2026-002", "WH002", 2, "Pending",
     [("A4 Paper Ream", "Pack", 20)]),
]


def _money(value) -> Decimal:
    return Decimal(str(value)).quantize(Decimal("0.01"))


def _ensure(session: Session, model, lookup: dict, values: Optional[dict] = None):
    """Return the row matching `lookup`, creating it from `lookup + values` if absent."""
    row = session.exec(select(model).filter_by(**lookup)).first()
    if row is not None:
        return row
    row = model(**lookup, **(values or {}))
    session.add(row)
    session.commit()
    session.refresh(row)
    return row


def _payment_status(total: Decimal, paid: Decimal) -> str:
    if paid <= 0:
        return "Unpaid"
    if paid < total:
        return "Partial"
    return "Paid"


def compute_stock_qty(base_qty: int, movements: list[int]) -> int:
    """On-hand quantity for one product in one warehouse.

    `movements` are signed: positive means stock in (purchase, transfer in,
    increase adjustment), negative means stock out (sale, transfer out,
    decrease adjustment).

    TODO(human): implement so the seeded WarehouseStock reconciles with the
    seeded transactions. Decide whether the result is allowed to go negative.
    """
    raise NotImplementedError


def _seed_master(session: Session) -> dict:
    currencies = {
        row.code: row for row in session.exec(select(Currency)).all()
    }
    units = {row.name: row for row in session.exec(select(Unit)).all()}
    payment_types = {
        row.name: row for row in session.exec(select(PaymentType)).all()
    }
    warehouse = _ensure(
        session,
        Warehouse,
        {"reference_no": "WH001"},
        {"name": "ទីទីម៉ាត ផ្លូវ 60", "location": "St. 60, Sen Sok", "note": "Main warehouse"},
    )
    warehouse_2 = _ensure(
        session,
        Warehouse,
        {"reference_no": "WH002"},
        {"name": "ទីទីម៉ាត ផ្សារថ្មី", "location": "St. 271, Toul Kork", "note": "Second warehouse"},
    )

    categories = {
        name: _ensure(session, Category, {"name": name}, {"description": description})
        for name, description in CATEGORIES.items()
    }
    suppliers = {
        name: _ensure(
            session,
            Supplier,
            {"name": name},
            {"phone": phone, "email": email, "map": map_url, "address": address, "status": True},
        )
        for name, phone, email, address, map_url in SUPPLIERS
    }
    customers = {
        name: _ensure(
            session,
            Customer,
            {"name": name},
            {"phone": phone, "address": address, "is_active": True},
        )
        for name, phone, address in CUSTOMERS
    }

    products = {
        name: _ensure(
            session,
            Product,
            {"barcode": barcode},
            {
                "name": name,
                "category_id": categories[category].id,
                "currency_id": currencies["USD"].id,
                "unit_id": units[unit].id,
                "photo": "",
                "cost_price": _money(cost),
                "sale_price": _money(price),
            },
        )
        for name, barcode, category, unit, cost, price in PRODUCTS
    }

    return {
        "warehouses": [warehouse, warehouse_2],
        "currency": currencies["USD"],
        "payment_type": payment_types["Cash"],
        "suppliers": suppliers,
        "customers": customers,
        "products": products,
    }


def _seed_purchases(session, data, movements):
    users = {u.name: u for u in session.exec(select(User)).all()}
    for invoice_no, supplier, wh_ref, days_ago, paid_ratio, items in PURCHASES:
        purchase = _ensure(
            session,
            Purchase,
            {"invoice_no": invoice_no},
            {
                "user_id": users["admin"].id,
                "supplier_id": data["suppliers"][supplier].id,
                "warehouse_id": _warehouse(data, wh_ref).id,
                "purchase_date": _days_ago(days_ago),
                "subtotal": _money(0),
                "tax_amount": _money(0),
                "discount_amount": _money(0),
                "total_amount": _money(0),
                "paid_amount": _money(0),
                "due_amount": _money(0),
                "payment_status": "Unpaid",
                "status": "Completed",
            },
        )
        if _has_items(session, PurchaseItem, purchase.id):
            continue

        subtotal = Decimal("0.00")
        for product_name, qty, cost in items:
            product = data["products"][product_name]
            line = _money(Decimal(cost) * qty)
            subtotal += line
            session.add(PurchaseItem(
                purchase_id=purchase.id,
                product_id=product.id,
                cost_price=_money(cost),
                qty=_money(qty),
                subtotal=line,
            ))
            movements.setdefault((product.id, purchase.warehouse_id), []).append(qty)

        paid = _money(subtotal * Decimal(paid_ratio))
        purchase.subtotal = subtotal
        purchase.total_amount = subtotal
        purchase.paid_amount = paid
        purchase.initial_paid_amount = paid
        purchase.due_amount = subtotal - paid
        purchase.payment_status = _payment_status(subtotal, paid)
        session.add(purchase)
        session.add(PurchasePayment(
            supplier_id=purchase.supplier_id,
            purchase_id=purchase.id,
            payment_type_id=data["payment_type"].id,
            currency_id=data["currency"].id,
            payment_no=f"PP-{invoice_no}",
            amount=float(paid),
            payment_date=_days_ago(days_ago),
            note="",
            status="Completed",
        ))
        session.commit()


def _seed_sales(session, data, movements):
    users = {u.name: u for u in session.exec(select(User)).all()}
    default_warehouse = data["warehouses"][0]
    for invoice_no, customer, days_ago, paid_ratio, items in SALES:
        sale = _ensure(
            session,
            Sale,
            {"invoice_no": invoice_no},
            {
                "user_id": users["cashier"].id,
                "customer_id": data["customers"][customer].id,
                "sale_date": _days_ago(days_ago),
                "subtotal": _money(0),
                "tax_amount": _money(0),
                "discount_amount": _money(0),
                "total_amount": _money(0),
                "paid_amount": _money(0),
                "due_amount": _money(0),
                "payment_status": "Unpaid",
                "status": "Completed",
                "payment_method": "Cash",
            },
        )
        if _has_items(session, SaleItems, sale.id, "sale_id"):
            continue

        subtotal = Decimal("0.00")
        for product_name, qty, price in items:
            product = data["products"][product_name]
            line = _money(Decimal(price) * qty)
            subtotal += line
            session.add(SaleItems(
                sale_id=sale.id,
                product_id=product.id,
                qty=qty,
                sale_price=_money(price),
                subtotal=line,
            ))
            # Sale has no warehouse_id; the app deducts from the product's
            # first stock row, so test stock is taken from the main warehouse.
            movements.setdefault((product.id, default_warehouse.id), []).append(-qty)

        paid = _money(subtotal * Decimal(paid_ratio))
        sale.subtotal = subtotal
        sale.total_amount = subtotal
        sale.paid_amount = paid
        sale.due_amount = subtotal - paid
        sale.payment_status = _payment_status(subtotal, paid)
        session.add(sale)
        if paid > 0:
            session.add(SalePayment(
                user_id=sale.user_id,
                sale_id=sale.id,
                amount=paid,
                payment_method="Cash",
                reference_no=f"SP-{invoice_no}",
                payment_date=_days_ago(days_ago),
                note="",
            ))
        session.commit()


def _seed_transfers(session, data, movements):
    for reference_no, from_ref, to_ref, days_ago, items in TRANSFERS:
        transfer = _ensure(
            session,
            ProductTransfer,
            {"reference_no": reference_no},
            {
                "from_warehouse_id": _warehouse(data, from_ref).id,
                "to_warehouse_id": _warehouse(data, to_ref).id,
                "transfer_date": _days_ago(days_ago),
            },
        )
        if _has_items(session, ProductTransferItem, transfer.id, "product_transfer_id"):
            continue
        for product_name, qty in items:
            product = data["products"][product_name]
            session.add(ProductTransferItem(
                product_id=product.id,
                product_transfer_id=transfer.id,
                qty=qty,
            ))
            movements.setdefault((product.id, transfer.from_warehouse_id), []).append(-qty)
            movements.setdefault((product.id, transfer.to_warehouse_id), []).append(qty)
        session.commit()


def _seed_adjustments(session, data, movements):
    users = {u.name: u for u in session.exec(select(User)).all()}
    for reference_no, wh_ref, product_name, kind, qty, days_ago in ADJUSTMENTS:
        adjustment = _ensure(
            session,
            StockAdjustment,
            {"reference_no": reference_no},
            {
                "product_id": data["products"][product_name].id,
                "warehouse_id": _warehouse(data, wh_ref).id,
                "user_id": users["stockmanager"].id,
                "adjustment_type": kind,
                "qty": qty,
                "previous_qty": 0,
                "new_qty": 0,
                "reason": "Stock count correction",
            },
        )
        sign = qty if kind == "increase" else -qty
        movements.setdefault((adjustment.product_id, adjustment.warehouse_id), []).append(sign)
    session.commit()


def _seed_purchase_requests(session, data):
    users = {u.name: u for u in session.exec(select(User)).all()}
    for request_no, wh_ref, days_ago, status, items in PURCHASE_REQUESTS:
        request = _ensure(
            session,
            PurchaseRequest,
            {"request_no": request_no},
            {
                "warehouse_id": _warehouse(data, wh_ref).id,
                "request_type": "Restock",
                "requested_by": users["stockmanager"].name,
                "approved_by": users["admin"].name if status == "Approved" else "",
                "status": status,
                "reason": "Low stock",
                "request_date": _days_ago(days_ago),
                "approved_date": _days_ago(days_ago) if status == "Approved" else _days_ago(days_ago),
            },
        )
        if _has_items(session, PurchaseRequestItems, request.id, "purchase_request_id"):
            continue
        for product_name, unit, qty in items:
            session.add(PurchaseRequestItems(
                purchase_request_id=request.id,
                product_id=data["products"][product_name].id,
                unit=unit,
                qty=qty,
            ))
        session.commit()


def _seed_stock(session, data, movements):
    for product in data["products"].values():
        for warehouse in data["warehouses"]:
            qty = compute_stock_qty(
                BASE_STOCK, movements.get((product.id, warehouse.id), [])
            )
            stock = session.exec(
                select(WarehouseStock).where(
                    WarehouseStock.product_id == product.id,
                    WarehouseStock.warehouse_id == warehouse.id,
                )
            ).first()
            if stock is None:
                session.add(WarehouseStock(
                    product_id=product.id,
                    warehouse_id=warehouse.id,
                    qty=qty,
                ))
            else:
                stock.qty = qty
                session.add(stock)
    session.commit()


def _days_ago(days: int) -> datetime:
    return datetime.now(timezone.utc) - timedelta(days=days)


def _warehouse(data, reference_no: str) -> Warehouse:
    return next(w for w in data["warehouses"] if w.reference_no == reference_no)


def _has_items(session: Session, model, parent_id: int, field: str = "purchase_id") -> bool:
    return session.exec(
        select(model).where(getattr(model, field) == parent_id)
    ).first() is not None


def create_test_data():
    with Session(engine) as session:
        data = _seed_master(session)
        movements: dict[tuple[int, int], list[int]] = {}
        _seed_purchases(session, data, movements)
        _seed_sales(session, data, movements)
        _seed_transfers(session, data, movements)
        _seed_adjustments(session, data, movements)
        _seed_purchase_requests(session, data)
        _seed_stock(session, data, movements)


if __name__ == "__main__":
    create_test_data()
    print("Test data seeded successfully!")