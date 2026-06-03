from sqlmodel import Session, select
from app.models.user import User
from app.schemas.user import UserCreate

def create_user(session: Session, user: UserCreate):
    db_user = User.from_orm(user)
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

def get_all_users(session: Session):
    return session.exec(select(User)).all()

def get_user(session: Session, user_id: int):
    return session.get(User, user_id)

def update_user(session: Session, user_id: int, user: UserCreate):
    db_user = session.get(User, user_id)
    if db_user:
        db_user.name = user.name
        db_user.email = user.email
        db_user.password = user.password
        session.add(db_user)
        session.commit()
        session.refresh(db_user)
    return db_user

def delete_user(session: Session, user_id: int):
    user = session.get(User, user_id)
    if user:
        session.delete(user)
        session.commit()
    return user