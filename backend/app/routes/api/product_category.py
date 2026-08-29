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
            p.photo
           
        FROM categories c
        LEFT JOIN product p
            ON p.category_id = c.id
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
               
            })

    return list(categories.values())