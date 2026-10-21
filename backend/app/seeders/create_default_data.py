from sqlmodel import Session, select

from backend.app.models.warehouse import Warehouse
from database import engine
from app.models.payment_type import PaymentType
from app.models.unit import Unit
from app.models.system_configuration import SystemConfiguration
from app.models.currency import Currency


DEFAULT_DATA = {
    Unit: [
        {"name": name, "short_name": short_name, "description": f"Measured by {name.lower()}"}
        for name, short_name in (("Piece", "pc"), ("Box", "box"), ("Pack", "pack"), ("Bottle", "btl"), ("Can", "can"), ("Kilogram", "kg"), ("Gram", "g"), ("Liter", "l"), ("Meter", "m"))
    ],
    PaymentType: [
        {"name": name, "description": f"{name} payment"}
        for name in ("Cash", "Bank Transfer", "ABA Bank", "ACLEDA Bank", "Credit Card", "Wing", "Cheque", "QR Payment")
    ],
    Warehouse:[
        { "name": "ទីទីម៉ាត ផ្លូវ 60","reference_no": "WH001", "location": "30 street siem reap", "note":"this is warehost 30 street"}
    ],
    Currency:[
        {"name": name, "code":code, "symbol": symbol, "exchange_rate": exchange_rate, "status": True}
        for name, code, symbol, exchange_rate in (("Riel", "KHR", "៛", 4000), ("Dollar", "USD", "$", 1))
    ],
    SystemConfiguration: [
        { "company_name": "ទីទីម៉ាត ផ្លូវ 60", "company_address":"ផ្លូវ 60", "phone":"012 345 678", "email":"titimart22@gmail.com", "default_currency_id": 1, "default_warehouse_id": 1, "default_payment_type_id": 1, "allow_discount": True, "tax_enabled": False, "low_stock_warning": 40}
    ]
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
