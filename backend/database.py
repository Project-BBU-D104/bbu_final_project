from dotenv import load_dotenv
import os
from sqlmodel import Session, create_engine

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
SQL_ECHO = os.getenv("SQL_ECHO", "false").lower() == "true"

engine = create_engine(
    DATABASE_URL,
    echo=SQL_ECHO,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=10,
    pool_recycle=280,  # recycle before MySQL drops idle connections
)


def get_session():
    with Session(engine) as session:
        yield session