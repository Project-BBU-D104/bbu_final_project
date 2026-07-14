from sqlmodel import Session, select

from database import engine
from app.models.role import Role
from app.models.user import User
from app.security import hash_password


def create_admin_user():
    with Session(engine) as session:

        admin_role = session.exec(
            select(Role).where(Role.name == "Admin")
        ).first()

        if not admin_role:
            admin_role = Role(
                name="Admin",
                description="System Administrator",
                is_active=True,
            )
            session.add(admin_role)
            session.commit()
            session.refresh(admin_role)

        admin_user = session.exec(
            select(User).where(User.email == "admin")
        ).first()

        if not admin_user:
            admin_user = User(
                name="admin",
                email="admin",
                password=hash_password("123456"),
                role_id=admin_role.id,
            )
            session.add(admin_user)
            session.commit()