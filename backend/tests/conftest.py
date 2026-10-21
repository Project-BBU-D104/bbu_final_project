import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

import app.models  # noqa: F401  (registers every table on SQLModel.metadata)
from app.models.category import Category
from app.models.currency import Currency
from app.models.unit import Unit
from app.models.warehouse import Warehouse


@pytest.fixture
def session():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session


@pytest.fixture
def seed(session):
    category = Category(name="Drinks")
    unit = Unit(name="Piece", short_name="pc")
    currency = Currency(name="US Dollar", code="USD", symbol="$", exchange_rate=1.0)
    warehouse_a = Warehouse(name="Main", reference_no="WH-1", location="A", note="")
    warehouse_b = Warehouse(name="Branch", reference_no="WH-2", location="B", note="")

    session.add_all([category, unit, currency, warehouse_a, warehouse_b])
    session.commit()
    for row in (category, unit, currency, warehouse_a, warehouse_b):
        session.refresh(row)

    return {
        "category": category,
        "unit": unit,
        "currency": currency,
        "warehouse_a": warehouse_a,
        "warehouse_b": warehouse_b,
    }
