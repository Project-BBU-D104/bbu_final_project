# backend/main.py
from contextlib import asynccontextmanager
from fastapi import Depends, FastAPI
from sqlmodel import Session, select
from database import Tests, create_db_and_tables, get_session


# This function runs when FastAPI starts up
@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()  # Automatically creates the database file and table
    yield


app = FastAPI(lifespan=lifespan)


# Route 1: Create a new item and save it to SQLite
@app.post("/tests/")
def create_item(item: Tests, session: Session = Depends(get_session)):
    session.add(item)
    session.commit()
    session.refresh(item)
    return item


# Route 2: Get all items from the SQLite table
@app.get("/items/")
def read_items(session: Session = Depends(get_session)):
    items = session.exec(select(Tests)).all()
    return items