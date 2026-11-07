# backend/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend

from app.core.cache import cache_key_builder, ORMJsonCoder
from app.routes import users_router,category_router,product_router,supplier_router,customer_router,role_router,audit_logs_router, warehouse_router,warehouse_stock_router, stock_adjustment_router, product_transfer_router, purchase_router, sale_router, sale_payment_router, telegram_router,auth_router, currency_router, payment_type_router, unit_router, purchase_payments_router,product_transfer_item_router,recent_purchase_router,product_category_router,system_configuration_router, purchase_requests_router, purchase_request_items_router, dashboard_router
from app.security import get_current_user, require_roles

@asynccontextmanager
async def lifespan(app: FastAPI):
    FastAPICache.init(
        InMemoryBackend(),
        prefix="fastapi-cache",
        key_builder=cache_key_builder,
        coder=ORMJsonCoder,
        expire=60,
    )
    yield


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
for router, dependency in (
    (users_router, require_roles("Admin")),
    (category_router, get_current_user),
    (supplier_router, get_current_user),
    (product_router, get_current_user),
    (customer_router, get_current_user),
    (role_router, require_roles("Admin")),
    (audit_logs_router, get_current_user),
    (warehouse_router, get_current_user),
    (warehouse_stock_router, get_current_user),
    (stock_adjustment_router, get_current_user),
    (product_transfer_router, get_current_user),
    (product_transfer_item_router, get_current_user),
    (purchase_router, get_current_user),
        (purchase_payments_router, get_current_user),
    (purchase_requests_router, get_current_user),
    (purchase_request_items_router, get_current_user),
    (sale_router, get_current_user),
    (sale_payment_router, get_current_user),
    (telegram_router, get_current_user),
    (currency_router, get_current_user),
    (payment_type_router, get_current_user),
    (unit_router, get_current_user),
    (recent_purchase_router, get_current_user),
    (dashboard_router, get_current_user),
    (product_category_router, get_current_user),
    (system_configuration_router, get_current_user),
):
    app.include_router(router, dependencies=[Depends(dependency)])

@app.get("/")
def root():
    return {"message": "Welcome to User Management API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
