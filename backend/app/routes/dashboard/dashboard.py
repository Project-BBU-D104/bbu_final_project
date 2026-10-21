from fastapi import APIRouter
from sqlalchemy import text
from database import engine

router = APIRouter(
    prefix="/api",
    tags=["Dashboard"],
)

# Used when no system configuration row has been saved yet.
DEFAULT_LOW_STOCK_WARNING = 50


def _rows(sql: str) -> list[dict]:
    with engine.connect() as conn:
        return [dict(row) for row in conn.execute(text(sql)).mappings().all()]


@router.get("/kpi-data")
def get_kpi_data():
    low_stock_threshold = (
        "COALESCE((SELECT low_stock_warning FROM system_configuration "
        f"ORDER BY id LIMIT 1), {DEFAULT_LOW_STOCK_WARNING})"
    )

    sql = f"""
        SELECT
            COALESCE((
                SELECT SUM(ws.qty * p.cost_price)
                FROM warehouse_stock AS ws
                JOIN product AS p ON p.id = ws.product_id
            ), 0) AS total_stock_value,
            COALESCE((
                SELECT COUNT(*)
                FROM (
                    SELECT p.id
                    FROM product AS p
                    JOIN warehouse_stock AS ws ON ws.product_id = p.id
                    GROUP BY p.id
                    HAVING SUM(ws.qty) <= {low_stock_threshold}
                ) AS low_stock
            ), 0) AS low_stock_alerts,
            COALESCE((
                SELECT SUM(si.qty)
                FROM sale_items AS si
                JOIN sales AS s ON s.id = si.sale_id
                WHERE s.status = 'completed'
                  AND s.deleted_at IS NULL
                  AND YEAR(s.sale_date) = YEAR(CURDATE())
                  AND MONTH(s.sale_date) = MONTH(CURDATE())
            ), 0) AS stock_movement
    """

    rows = _rows(sql)
    return rows[0] if rows else {
        "total_stock_value": 0,
        "low_stock_alerts": 0,
        "stock_movement": 0,
    }


@router.get("/monthly-sales")
def get_monthly_sales():
    sql = """
        SELECT sale_year, sale_month, amount
        FROM (
            SELECT
                YEAR(s.sale_date) AS sale_year,
                MONTH(s.sale_date) AS sale_month,
                SUM(s.total_amount) AS amount
            FROM sales AS s
            WHERE s.status = 'completed'
              AND s.deleted_at IS NULL
            GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
            ORDER BY sale_year DESC, sale_month DESC
            LIMIT 12
        ) AS recent_months
        ORDER BY sale_year ASC, sale_month ASC
    """

    return _rows(sql)


@router.get("/revenue-by-category")
def get_revenue_by_category():
    sql = """
        SELECT
            c.name AS category,
            COALESCE(SUM(si.subtotal), 0) AS amount
        FROM sale_items AS si
        JOIN sales AS s ON s.id = si.sale_id
        JOIN product AS p ON p.id = si.product_id
        JOIN categories AS c ON c.id = p.category_id
        WHERE s.status = 'completed'
          AND s.deleted_at IS NULL
        GROUP BY c.id, c.name
        ORDER BY amount DESC
        LIMIT 8
    """

    return _rows(sql)


@router.get("/low-stock-products")
def get_low_stock_products():
    low_stock_threshold = (
        "COALESCE((SELECT low_stock_warning FROM system_configuration "
        f"ORDER BY id LIMIT 1), {DEFAULT_LOW_STOCK_WARNING})"
    )

    sql = f"""
        SELECT
            p.id AS id,
            p.name AS product_name,
            p.sale_price AS price,
            COALESCE(SUM(ws.qty), 0) AS stock_quantity
        FROM product AS p
        JOIN warehouse_stock AS ws ON ws.product_id = p.id
        GROUP BY p.id, p.name, p.sale_price
        HAVING SUM(ws.qty) <= {low_stock_threshold}
        ORDER BY stock_quantity ASC
        LIMIT 5
    """

    return _rows(sql)


@router.get("/top-selling-products")
def get_top_selling_products():
    sql = """
        SELECT
            p.id AS product_id,
            p.name AS product_name,
            SUM(si.qty) AS total_sold,
            SUM(si.subtotal) AS total_revenue
        FROM sale_items AS si
        JOIN sales AS s ON s.id = si.sale_id
        JOIN product AS p ON p.id = si.product_id
        WHERE s.status = 'completed'
          AND s.deleted_at IS NULL
        GROUP BY p.id, p.name
        ORDER BY total_sold DESC
        LIMIT 10
    """

    return _rows(sql)
