# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
# from database import create_tests_table_only
from app.routes import users_router,category_router,product_router,supplier_router,customer_router,role_router,audit_logs_router

app = FastAPI()



# Add CORS middleware (optional, for frontend requests)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routers
app.include_router(users_router)
app.include_router(category_router)
app.include_router(product_router)
app.include_router(supplier_router)
app.include_router(customer_router)
app.include_router(role_router)
app.include_router(audit_logs_router)

@app.get("/")
def root():
    return {"message": "Welcome to User Management API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}


# @app.on_event("startup")
# def startup():
#     create_tests_table_only()