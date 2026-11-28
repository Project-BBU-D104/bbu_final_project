from fastapi import APIRouter
from sqlalchemy import text
from database import engine

router = APIRouter(
    prefix="/api/product-category",
    tags=["Product Category"]
)

@router.get("/")
def get_product_category():

    sql = text("""
        SELECT
            c.id AS category_id,
            c.name AS category_name,
            p.id AS product_id,
            p.name AS product_name,
            p.photo,
            p.sale_price,
            p.barcode,
            p.currency_id,
            product_currency.name AS currency_name,
            product_currency.code AS currency_code,
            product_currency.symbol AS currency_symbol,
            COALESCE(SUM(ws.qty), 0) AS qty
           
        FROM categories c
        JOIN product p
            ON p.category_id = c.id
        JOIN warehouse_stock ws
            ON ws.product_id = p.id
        LEFT JOIN currency product_currency
            ON product_currency.id = p.currency_id
        GROUP BY
            c.id,
            c.name,
            p.id,
            p.name,
            p.photo,
            p.sale_price,
            p.barcode,
            p.currency_id,
            product_currency.name,
            product_currency.code,
            product_currency.symbol
        ORDER BY c.id, p.id
    """)

    with engine.connect() as conn:
        result = conn.execute(sql).mappings().all()

    categories = {}

    for row in result:
        category_id = row["category_id"]

        if category_id not in categories:
            categories[category_id] = {
                "id": category_id,
                "name": row["category_name"],
                "products": []
            }

        if row["product_id"] is not None:
            categories[category_id]["products"].append({
                "id": row["product_id"],
                "name": row["product_name"],
                "photo": row["photo"],
                "sale_price": row["sale_price"],
                "barcode": row["barcode"],
                "currency_id": row["currency_id"],
                "currency": {
                    "id": row["currency_id"],
                    "name": row["currency_name"],
                    "code": row["currency_code"],
                    "symbol": row["currency_symbol"],
                } if row["currency_code"] is not None else None,
                "qty": int(row["qty"])
            })

    return list(categories.values())
