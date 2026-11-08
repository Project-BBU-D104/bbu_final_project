from datetime import datetime, timezone

from fastapi import HTTPException
from sqlmodel import Session, select
from sqlalchemy.orm import joinedload
from app.models.user import User
from app.schemas.user.user import PasswordChange, ProfileUpdate, UserCreate

from app.security import hash_password, verify_password

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
    # Load the role eagerly: fastapi_cache encodes the returned ORM object
    # before FastAPI's response_model runs, so a lazily-loaded relationship
    # would be missing from the cached payload and the next cache hit would
    # fail response validation ("role: Field required").
    return session.exec(
        select(User).options(joinedload(User.role)).where(User.id == user_id)
    ).first()

def update_user(session: Session, user_id: int, user: UserCreate):
    db_user = session.get(User, user_id)
    if db_user:
        db_user.name = user.name
        db_user.email = user.email
        # A blank password means "keep the stored one" (the edit form never
        # receives it), so an admin editing contacts cannot wipe the login.
        if user.password and user.password.strip():
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

def update_profile(session: Session, current_user: User, profile: ProfileUpdate):
    # `name` is the login identifier (auth_service matches on it), so a
    # self-service rename must not take an account that already exists.
    duplicate = session.exec(
        select(User).where(
            User.name == profile.name,
            User.id != current_user.id,
        )
    ).first()
    if duplicate is not None:
        raise HTTPException(
            status_code=409,
            detail="Name is already in use",
        )

    current_user.name = profile.name
    current_user.email = profile.email
    current_user.phone = profile.phone
    current_user.photo = profile.photo
    current_user.updated_at = datetime.now(timezone.utc)

    session.add(current_user)
    session.commit()
    session.refresh(current_user)
    return current_user

def change_password(session: Session, current_user: User, passwords: PasswordChange):
    if not verify_password(passwords.current_password, current_user.password):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect",
        )

    current_user.password = hash_password(passwords.new_password)
    current_user.updated_at = datetime.now(timezone.utc)

    session.add(current_user)
    session.commit()
    session.refresh(current_user)
    return {"message": "Password changed successfully."}