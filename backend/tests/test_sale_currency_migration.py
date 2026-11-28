import importlib.util
from pathlib import Path

import sqlalchemy as sa
from alembic.migration import MigrationContext
from alembic.operations import Operations


def test_currency_snapshot_migration_preserves_existing_rows():
    path = Path(__file__).parents[1] / "alembic/versions/c72d9b34e610_sale_currency_snapshot.py"
    spec = importlib.util.spec_from_file_location("sale_currency_migration", path)
    migration = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migration)
    engine = sa.create_engine("sqlite://")
    with engine.begin() as connection:
        connection.execute(sa.text("CREATE TABLE sales (id INTEGER PRIMARY KEY)"))
        connection.execute(sa.text("CREATE TABLE sale_items (id INTEGER PRIMARY KEY)"))
        connection.execute(sa.text("INSERT INTO sales (id) VALUES (1)"))
        connection.execute(sa.text("INSERT INTO sale_items (id) VALUES (1)"))
        with Operations.context(MigrationContext.configure(connection)):
            migration.upgrade()
            assert connection.execute(sa.text("SELECT currency_code FROM sales")).scalar_one() is None
            assert connection.execute(sa.text("SELECT original_unit_price FROM sale_items")).scalar_one() is None
            migration.downgrade()
        assert {col["name"] for col in sa.inspect(connection).get_columns("sales")} == {"id"}
        assert {col["name"] for col in sa.inspect(connection).get_columns("sale_items")} == {"id"}
