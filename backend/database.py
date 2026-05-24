# backend/database.py
from typing import Optional
from sqlmodel import Field, Session, SQLModel, create_engine

# 1. Setup the SQLite Database file
sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

# connect_args={"check_same_thread": False} is required ONLY for SQLite
engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})


# 2. Define your Database Table (Model)
class Tests(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None
    price: float


# 3. Helper function to create the table in the DB file
def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


# 4. Helper function to get a database session for API routes
def get_session():
    with Session(engine) as session:
        yield session