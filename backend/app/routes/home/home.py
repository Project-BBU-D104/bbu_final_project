from fastapi import APIRouter
from sqlalchemy import text
from database import engine

router = APIRouter(
    prefix="/api",
    tags=["Home"],
)

@router.get("/recent-purchases")
def get_recent_purchases():

    sql = text("""
        SELECT
            p.id AS purchase_id,
            p.invoice_no AS invoice_no,
            p.purchase_date AS purchase_date,

            pi.id AS purchase_item_id,
            pi.product_id AS product_id,
            pi.qty AS qty,
            pi.cost_price AS cost_price,
            pi.subtotal AS subtotal,
            
            pr.name AS product_name,
           
            c.name AS category_name,

            sup.name AS supplier_name
        FROM purchases p

        LEFT JOIN purchase_items pi
            ON pi.purchase_id = p.id

        LEFT JOIN product pr
            ON pr.id = pi.product_id

        LEFT JOIN supplier sup
            ON sup.id = p.supplier_id

        LEFT JOIN categories c
            ON c.id = pr.category_id

        ORDER BY p.id DESC, pi.id ASC

        LIMIT 5
    """)

    with engine.connect() as conn:
        result = conn.execute(sql).mappings().all()

    return result


@router.get("/recent-sales")
def get_recent_sales():
    sql = text("""
        SELECT
            s.id AS sale_id,
            s.invoice_no AS invoice_no,
            s.sale_date AS sale_date,
            s.subtotal AS subtotal,
            s.total_amount AS total_amount,
            s.currency_code AS currency_code,
            s.currency_symbol AS currency_symbol,
            cu.name AS customer_name
        FROM sales s
        LEFT JOIN customers cu
            ON cu.id = s.customer_id
        ORDER BY s.id DESC
        LIMIT 5

    """)

    with engine.connect() as conn:
        result = conn.execute(sql).mappings().all()

    return result
