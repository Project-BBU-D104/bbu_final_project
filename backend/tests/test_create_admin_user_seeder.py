import pytest
from sqlmodel import select

from app.models.role import Role
from app.models.system_configuration import SystemConfiguration
from app.models.user import User
from app.seeders.create_admin_user import (
    create_default_user,
    get_default_system_configuration,
)


def make_configuration(session, seed, name, low_stock_warning):
    configuration = SystemConfiguration(
        company_name=name,
        default_currency_id=seed["currency"].id,
        low_stock_warning=low_stock_warning,
    )
    session.add(configuration)
    session.commit()
    session.refresh(configuration)
    return configuration


def seed_user(session, system_configuration_id, **kwargs):
    return create_default_user(
        session=session,
        role_name="Admin",
        role_description="System Administrator",
        username="admin",
        email="admin",
        password="123456",
        system_configuration_id=system_configuration_id,
        **kwargs,
    )


def test_get_default_system_configuration_returns_the_first_one(session, seed):
    first = make_configuration(session, seed, "First shop", 5)
    make_configuration(session, seed, "Second shop", 99)

    configuration = get_default_system_configuration(session)

    assert configuration.id == first.id


def test_get_default_system_configuration_fails_without_a_configuration(session):
    with pytest.raises(RuntimeError):
        get_default_system_configuration(session)


def test_create_default_user_activates_new_user(session, seed):
    configuration = make_configuration(session, seed, "Main shop", 10)

    seed_user(session, configuration.id)

    user = session.exec(select(User).where(User.email == "admin")).first()
    assert user.is_active is True


def test_create_default_user_assigns_system_configuration(session, seed):
    configuration = make_configuration(session, seed, "Main shop", 10)

    seed_user(session, configuration.id)

    user = session.exec(select(User).where(User.email == "admin")).first()
    assert user.system_configuration_id == configuration.id


def test_create_default_user_assigns_configuration_to_existing_user(session, seed):
    role = Role(name="Admin", description="System Administrator", is_active=True)
    session.add(role)
    session.commit()
    session.refresh(role)

    existing = User(
        name="admin",
        email="admin",
        password="already-hashed",
        role_id=role.id,
    )
    session.add(existing)
    session.commit()
    session.refresh(existing)

    configuration = make_configuration(session, seed, "Main shop", 10)

    seed_user(session, configuration.id)

    session.refresh(existing)
    assert existing.system_configuration_id == configuration.id
