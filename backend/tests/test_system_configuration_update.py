from app.crud.system_configuration.system_configuration import (
    update_system_configuration,
)
from app.models.payment_type import PaymentType
from app.models.system_configuration import SystemConfiguration
from app.schemas.system_configuration.system_configuration import (
    SystemConfigurationUpdate,
)


def make_configuration(session, seed, warehouse_id, payment_type_id):
    configuration = SystemConfiguration(
        company_name="Main shop",
        default_currency_id=seed["currency"].id,
        default_warehouse_id=warehouse_id,
        default_payment_type_id=payment_type_id,
    )
    session.add(configuration)
    session.commit()
    session.refresh(configuration)
    return configuration


def test_update_can_clear_default_warehouse(session, seed):
    configuration = make_configuration(
        session, seed, seed["warehouse_a"].id, None
    )

    updated = update_system_configuration(
        session,
        configuration.id,
        SystemConfigurationUpdate(
            default_currency_id=seed["currency"].id,
            default_warehouse_id=None,
        ),
    )

    assert updated.default_warehouse_id is None


def test_update_can_clear_default_payment_type(session, seed):
    payment_type = PaymentType(name="Cash")
    session.add(payment_type)
    session.commit()
    session.refresh(payment_type)

    configuration = make_configuration(
        session, seed, None, payment_type.id
    )

    updated = update_system_configuration(
        session,
        configuration.id,
        SystemConfigurationUpdate(
            default_currency_id=seed["currency"].id,
            default_payment_type_id=None,
        ),
    )

    assert updated.default_payment_type_id is None
