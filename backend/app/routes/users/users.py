from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.user.user import UserCreate, UserRead
from app.crud.user.user import create_user, get_all_users, get_user, update_user, delete_user

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserRead)
def create_new_user(user: UserCreate, session: Session = Depends(get_session)):
    return create_user(session, user)

@router.get("/", response_model=list[UserRead])
def read_all_users(session: Session = Depends(get_session)):
    return get_all_users(session)

@router.get("/{user_id}", response_model=UserRead)
def read_user(user_id: int, session: Session = Depends(get_session)):
    return get_user(session, user_id)

@router.put("/{user_id}", response_model=UserRead)
def update_user_route(user_id: int, user: UserCreate, session: Session = Depends(get_session)):
    return update_user(session, user_id, user)

@router.delete("/{user_id}")
def delete_user_route(user_id: int, session: Session = Depends(get_session)):
    return delete_user(session, user_id)