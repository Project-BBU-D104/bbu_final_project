from sqlmodel import Session, select

from database import engine
from app.models.role import Role
from app.models.user import User
from app.security import hash_password


def create_default_user(
    session: Session,
    role_name: str,
    role_description: str,
    username: str,
    email: str,
    password: str,
):
    # Check role
    role = session.exec(
        select(Role).where(Role.name == role_name)
    ).first()

    if not role:
        role = Role(
            name=role_name,
            description=role_description,
            is_active=True,
        )
        session.add(role)
        session.commit()
        session.refresh(role)

    # Check user
    user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if not user:
        user = User(
            name=username,
            email=email,
            password=hash_password(password),
            role_id=role.id,
        )
        session.add(user)
        session.commit()


def create_admin_user():
    with Session(engine) as session:

        # ==========================
        # Admin
        # ==========================
        create_default_user(
            session=session,
            role_name="Admin",
            role_description="System Administrator",
            username="admin",
            email="admin",
            password="123456",
        )

        # ==========================
        # Cashier
        # ==========================
        create_default_user(
            session=session,
            role_name="Cashier",
            role_description="Cashier",
            username="cashier",
            email="cashier",
            password="123456",
        )

        # ==========================
        # Stock Manager
        # ==========================
        create_default_user(
            session=session,
            role_name="Stock Manager",
            role_description="Warehouse Stock Manager",
            username="stockmanager",
            email="stockmanager",
            password="123456",
        )