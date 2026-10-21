from app.crud.system_configuration.system_configuration import (
    DEFAULT_LOW_STOCK_WARNING,
    get_low_stock_warning,
)
from app.crud.user.user import create_user
from app.models.role import Role
from app.models.system_configuration import SystemConfiguration
from app.schemas.user.user import UserCreate


def make_role(session):
    role = Role(name="Admin")
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


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


def make_user_payload(role, system_configuration_id):
    return UserCreate(
        name="sabrey",
        email="sabrey@example.com",
        password="secret",
        is_active=True,
        role_id=role.id,
        phone=None,
        photo=None,
        system_configuration_id=system_configuration_id,
    )


def test_create_user_stores_system_configuration_id(session, seed):
    role = make_role(session)
    configuration = make_configuration(session, seed, "Shop A", 5)

    user = create_user(session, make_user_payload(role, configuration.id))

    assert getattr(user, "system_configuration_id", None) == configuration.id


def test_low_stock_warning_uses_the_users_configuration(session, seed):
    first = make_configuration(session, seed, "First shop", 5)
    second = make_configuration(session, seed, "Second shop", 99)

    assert get_low_stock_warning(session, second.id) == 99
    assert get_low_stock_warning(session, first.id) == 5


def test_low_stock_warning_falls_back_to_the_first_configuration(session, seed):
    make_configuration(session, seed, "First shop", 5)
    make_configuration(session, seed, "Second shop", 99)

    assert get_low_stock_warning(session, None) == 5


def test_low_stock_warning_defaults_when_no_configuration_exists(session):
    assert get_low_stock_warning(session, None) == DEFAULT_LOW_STOCK_WARNING
