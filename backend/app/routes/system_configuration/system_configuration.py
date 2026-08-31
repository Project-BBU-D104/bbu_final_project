from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.system_configuration.system_configuration import SystemConfigurationCreate, SystemConfigurationRead, SystemConfigurationUpdate
from app.crud.system_configuration.system_configuration import  create_system_configuration, get_all_system_configuration, get_system_configuration, update_system_configuration, delete_system_configuration

router = APIRouter(prefix="/system_configuration", tags=["system_configuration"])

@router.post("/", response_model=SystemConfigurationRead)
def create_new_system_configuration(system_configuration: SystemConfigurationCreate, session: Session = Depends(get_session)):
    return create_system_configuration(session, system_configuration)

@router.get("/", response_model=list[SystemConfigurationRead])
def read_all_system_configuration(session: Session = Depends(get_session)):
    return get_all_system_configuration(session)

@router.get("/{system_configuration_id}", response_model=SystemConfigurationRead)
def read_system_configuration(system_configuration_id: int, session: Session = Depends(get_session)):
    return get_system_configuration(session, system_configuration_id)

@router.put("/{system_configuration_id}", response_model=SystemConfigurationRead)
def update_system_configuration_route(system_configuration_id: int, system_configuration: SystemConfigurationUpdate, session: Session = Depends(get_session)):
    return update_system_configuration(session, system_configuration_id, system_configuration)

@router.delete("/{system_configuration_id}")
def delete_system_configuration_route(system_configuration_id: int, session: Session = Depends(get_session)):
    return delete_system_configuration(session, system_configuration_id)