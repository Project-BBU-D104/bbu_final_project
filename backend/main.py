# backend/main.py
from contextlib import asynccontextmanager
from fastapi import Depends, FastAPI
from sqlmodel import Session, select
from fastapi.middleware.cors import CORSMiddleware
from database import Tests, create_db_and_tables, get_session
from app.routes import users_router

# This function runs when FastAPI starts up
@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()  # Automatically creates the database file and table
    yield


app = FastAPI(lifespan=lifespan)


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

@app.get("/")
def root():
    return {"message": "Welcome to User Management API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}