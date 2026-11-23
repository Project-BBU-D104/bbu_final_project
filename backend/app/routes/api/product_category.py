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
            w.id AS warehouse_id,
            w.name AS warehouse_name,
            COALESCE(SUM(ws.qty), 0) AS qty
           
        FROM categories c
        JOIN product p
            ON p.category_id = c.id
        JOIN warehouse_stock ws
            ON ws.product_id = p.id
        JOIN warehouses w ON w.id = ws.warehouse_id
        GROUP BY
            c.id,
            c.name,
            p.id,
            p.name,
            p.photo,
            p.sale_price,
            p.barcode, w.id, w.name
        ORDER BY c.id, p.id, w.id
    """)

    with engine.connect() as conn:
        result = conn.execute(sql).mappings().all()

    categories = {}
    products = {}

    for row in result:
        category_id = row["category_id"]

        if category_id not in categories:
            categories[category_id] = {
                "id": category_id,
                "name": row["category_name"],
                "products": []
            }

        if row["product_id"] not in products:
            product = {
                "id": row["product_id"],
                "name": row["product_name"],
                "photo": row["photo"],
                "sale_price": row["sale_price"],
                "barcode": row["barcode"],
                "qty": 0,
                "warehouse_availability": [],
            }
            products[row["product_id"]] = product
            categories[category_id]["products"].append(product)
        product = products[row["product_id"]]
        qty = int(row["qty"])
        product["qty"] += qty
        product["warehouse_availability"].append({
            "warehouse_id": row["warehouse_id"],
            "warehouse_name": row["warehouse_name"],
            "qty": qty,
        })

    return list(categories.values())