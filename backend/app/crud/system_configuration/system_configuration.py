from sqlmodel import Session, select, or_
from app.models.system_configuration import SystemConfiguration
from app.schemas.system_configuration.system_configuration import SystemConfigurationCreate, SystemConfigurationUpdate
from datetime import datetime

def create_system_configuration(session: Session, system_configuration: SystemConfigurationCreate):
    db_system_configuration = SystemConfiguration.from_orm(system_configuration)
    session.add(db_system_configuration)
    session.commit()
    session.refresh(db_system_configuration)
    return db_system_configuration

def get_all_system_configuration(session: Session):
    return session.exec(select(SystemConfiguration)).all()

def get_system_configuration(session: Session, system_configuration_id: int):
    return session.get(SystemConfiguration, system_configuration_id)

def update_system_configuration(session: Session, system_configuration_id: int, system_configuration: SystemConfigurationUpdate):
    db_system_configuration = session.get(SystemConfiguration, system_configuration_id)
    if db_system_configuration:
        if system_configuration.company_name is not None:
            db_system_configuration.company_name = system_configuration.company_name
        if system_configuration.company_address is not None:
            db_system_configuration.company_address = system_configuration.company_address
        if system_configuration.phone is not None:
            db_system_configuration.phone = system_configuration.phone
        if system_configuration.email is not None:
            db_system_configuration.email = system_configuration.email
        if system_configuration.logo is not None:
            db_system_configuration.logo = system_configuration.logo
        if system_configuration.default_currency_id is not None:
            db_system_configuration.default_currency_id = system_configuration.default_currency_id
        if system_configuration.default_warehouse_id is not None:
            db_system_configuration.default_warehouse_id = system_configuration.default_warehouse_id
        if system_configuration.default_payment_type_id is not None:
            db_system_configuration.default_payment_type_id = system_configuration.default_payment_type_id
        if system_configuration.allow_discount is not None:
            db_system_configuration.allow_discount = system_configuration.allow_discount
        if system_configuration.tax_enabled is not None:
            db_system_configuration.tax_enabled = system_configuration.tax_enabled
        if system_configuration.low_stock_warning is not None:
            db_system_configuration.low_stock_warning = system_configuration.low_stock_warning

        db_system_configuration.updated_at = system_configuration.updated_at or datetime.utcnow()
        session.add(db_system_configuration)
        session.commit()
        session.refresh(db_system_configuration)
    return db_system_configuration

def delete_system_configuration(session: Session, system_configuration_id: int):
    system_configuration = session.get(SystemConfiguration, system_configuration_id)
    if system_configuration:
        session.delete(system_configuration)
        session.commit()
    return system_configuration