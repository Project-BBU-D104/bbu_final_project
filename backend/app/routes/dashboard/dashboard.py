from fastapi import APIRouter
from sqlalchemy import text
from database import engine

router = APIRouter(
    prefix="/api",
    tags=["Dashboard"],
)

@router.get("/kpi-data")
def get_kpi_data():

    sql = text("""

        """)
    
@router.get("/monthly-sales")
def get_monthly_sales():

    sql = text("""

        """)

@router.get("/revenue-by-category")
def get_revenue_by_category():

    sql = text("""

        """)
    
@router.get("/low-stock-products")
def get_low_stock_products():

    sql = text("""

        """)

@router.get("/top-selling-products")
def get_top_selling_products():

    sql = text("""

        """)