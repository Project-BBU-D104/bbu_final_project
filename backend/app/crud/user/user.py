from sqlmodel import Session, select
from sqlalchemy.orm import joinedload
from app.models.user import User
from app.schemas.user.user import UserCreate

from app.security import hash_password

def create_user(session: Session, user: UserCreate):
    db_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        is_active=user.is_active,
        role_id=user.role_id,
        system_configuration_id=user.system_configuration_id,
        phone=user.phone,
        photo=user.photo
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

def get_all_users(session: Session):
    return session.exec(
        select(User).options(joinedload(User.role))
    ).all()

def get_user(session: Session, user_id: int):
    return session.get(User, user_id)

def update_user(session: Session, user_id: int, user: UserCreate):
    db_user = session.get(User, user_id)
    if db_user:
        db_user.name = user.name
        db_user.email = user.email
        db_user.password = hash_password(user.password)
        db_user.is_active = user.is_active
        db_user.phone = user.phone
        db_user.photo = user.photo
        db_user.role_id = user.role_id
        if user.system_configuration_id is not None:
            db_user.system_configuration_id = user.system_configuration_id

        session.add(db_user)
        session.commit()
        session.refresh(db_user)
    return db_user

def delete_user(session: Session, user_id: int):
    user = session.get(User, user_id)
    if user:
        session.delete(user)
        session.commit()
    return {
        "message": "User deleted successfully.",
        "user": user
    }