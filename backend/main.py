# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
# from database import create_tests_table_only

from contextlib import asynccontextmanager
from app.seeders.create_admin_user import create_admin_user
from app.routes import users_router,category_router,product_router,supplier_router,customer_router,role_router,audit_logs_router, warehouse_router,warehouse_stock_router, stock_adjustment_router, product_transfer_router, purchase_router,purchase_item_router, sale_router, sale_payment_router, telegram_router,auth_router, currency_router, payment_type_router, unit_router, purchase_requests_router, purchase_request_items_router, purchase_payments_router,product_transfer_item_router,recent_purchase_router

app = FastAPI()


# create user 
# if this uncomment when create table new pls uncomment
# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     create_admin_user()
#     yield

# app = FastAPI(lifespan=lifespan)

# Add CORS middleware (optional, for frontend requests)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routers
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(category_router)
app.include_router(supplier_router)
app.include_router(product_router)  
app.include_router(customer_router)
app.include_router(role_router)
app.include_router(audit_logs_router)
app.include_router(warehouse_router)
app.include_router(warehouse_stock_router)
app.include_router(stock_adjustment_router)
app.include_router(product_transfer_router)
app.include_router(product_transfer_item_router)
app.include_router(purchase_router)
app.include_router(purchase_item_router)
app.include_router(sale_router)
app.include_router(sale_payment_router)
app.include_router(telegram_router)
app.include_router(currency_router)
app.include_router(payment_type_router)
app.include_router(unit_router)

app.include_router(recent_purchase_router)

# app.include_router(purchase_requests_router)
# app.include_router(purchase_request_items_router)
app.include_router(purchase_payments_router)

@app.get("/")
def root():
    return {"message": "Welcome to User Management API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

# @app.on_event("startup")
# def startup():
#     create_tests_table_only()