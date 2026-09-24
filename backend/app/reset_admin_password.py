# for reset password user
# PS F:\ProjectSarona\bbu_final_project\backend> python -m app.reset_admin_password

from sqlmodel import Session, select

from database import engine
from app.models.user import User
from app.security import hash_password


with Session(engine) as session:

    user = session.exec(
        select(User).where(User.name == "cashier")
    ).first()

    if user is None:
        print("Cashier user not found")
    else:
        user.password = hash_password("123456")

        session.add(user)
        session.commit()

        print("Admin password reset successfully")