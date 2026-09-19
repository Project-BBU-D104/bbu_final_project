from sqlmodel import Session, select

from database import engine
from app.models.category import Category
from app.models.customer import Customer
from app.models.payment_type import PaymentType
from app.models.supplier import Supplier
from app.models.unit import Unit


DEFAULT_DATA = {
    Category: [
        {"name": name, "description": f"{name} products"}
        for name in ("Beverages", "Snacks", "Dairy", "Bakery", "Produce", "Frozen", "Meat", "Seafood", "Household", "Personal Care")
    ],
    Customer: [
        {"name": f"Customer {number}", "phone": f"01234567{number:02}", "address": "Phnom Penh", "is_active": True}
        for number in range(1, 11)
    ],
    Supplier: [
        {"name": f"Supplier {number}", "phone": f"0234567{number:03}", "email": f"supplier{number}@example.com", "map": "Phnom Penh", "address": "Phnom Penh", "status": True}
        for number in range(1, 11)
    ],
    Unit: [
        {"name": name, "short_name": short_name, "description": f"Measured by {name.lower()}"}
        for name, short_name in (("Piece", "pc"), ("Box", "box"), ("Pack", "pack"), ("Bottle", "btl"), ("Can", "can"), ("Kilogram", "kg"), ("Gram", "g"), ("Liter", "l"), ("Meter", "m"), ("Dozen", "dz"))
    ],
    PaymentType: [
        {"name": name, "description": f"{name} payment"}
        for name in ("Cash", "Bank Transfer", "Credit Card", "Debit Card", "ABA Pay", "Wing", "ACLEDA", "Cheque", "QR Payment", "Credit")
    ],
}


def create_default_data():
    with Session(engine) as session:
        for model, rows in DEFAULT_DATA.items():
            existing_names = {row.name for row in session.exec(select(model)).all()}
            session.add_all(model(**row) for row in rows if row["name"] not in existing_names)
        session.commit()


if __name__ == "__main__":
    assert all(len(rows) == 10 for rows in DEFAULT_DATA.values())
    create_default_data()
    print("Default data seeded successfully!")
