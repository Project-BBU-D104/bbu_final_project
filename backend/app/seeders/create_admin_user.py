from typing import Optional

from sqlmodel import Session, select

from database import engine
from app.models.role import Role
from app.models.system_configuration import SystemConfiguration
from app.models.user import User
from app.security import hash_password


def get_default_system_configuration(
    session: Session,
) -> SystemConfiguration:
    """Return the first system configuration, which new users are attached to."""
    configuration = session.exec(
        select(SystemConfiguration).order_by(SystemConfiguration.id)
    ).first()

    if configuration is None:
        raise RuntimeError(
            "No system configuration found. Run "
            "'python -m app.seeders.create_default_data' first."
        )

    return configuration


def create_default_user(
    session: Session,
    role_name: str,
    role_description: str,
    username: str,
    email: str,
    password: str,
    system_configuration_id: int,
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
            system_configuration_id=system_configuration_id,
            is_active=True,
        )
        session.add(user)
        session.commit()
    elif user.system_configuration_id is None:
        # Keep existing assignments, but attach users created before
        # configurations existed.
        user.system_configuration_id = system_configuration_id
        session.add(user)
        session.commit()

    return user


def create_admin_user(system_configuration_id: Optional[int] = None):
    with Session(engine) as session:
        if system_configuration_id is None:
            system_configuration_id = get_default_system_configuration(session).id

        # Admin
        create_default_user(
            session=session,
            role_name="Admin",
            role_description="System Administrator",
            username="admin",
            email="admin",
            password="123456",
            system_configuration_id=system_configuration_id,
        )

        # Supervisor (below Admin)
        if not session.exec(select(Role).where(Role.name == "Supervisor")).first():
            session.add(Role(
                name="Supervisor",
                description="Supervisor",
                is_active=True,
            ))
            session.commit()

        # Cashier
        create_default_user(
            session=session,
            role_name="Cashier",
            role_description="Cashier",
            username="cashier",
            email="cashier",
            password="123456",
            system_configuration_id=system_configuration_id,
        )

        # Stock Manager
        create_default_user(
            session=session,
            role_name="Stock Manager",
            role_description="Warehouse Stock Manager",
            username="stockmanager",
            email="stockmanager",
            password="123456",
            system_configuration_id=system_configuration_id,
        )

if __name__ == "__main__":
    print("Starting seeding process...")
    create_admin_user()
    print("Seeding completed successfully!")
