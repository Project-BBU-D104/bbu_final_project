from sqlmodel import Session

from database import engine
from app.models.user import User
from app.security import hash_password

with Session(engine) as session:
    user = User(
        name="admin",
        password=hash_password("123456"),
    )

    session.add(user)
    session.commit()

print("Admin created.")


# python create_admin.py