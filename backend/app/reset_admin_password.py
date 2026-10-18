# for reset password user
# PS F:\ProjectSarona\bbu_final_project\backend> python -m app.reset_admin_password

from sqlmodel import Session, select

from database import engine
from app.models.user import User
from app.security import hash_password


with Session(engine) as session:

    user = session.exec(
        # select(User).where(User.name == "cashier")
        select(User).where(User.name == "admin")
    ).first()

    if user is None:
        print("Admin user not found")
    else:
        user.password = hash_password("123456")

        session.add(user)
        session.commit()

        print("Admin password reset successfully")
        # print("Cashier password reset successfully")