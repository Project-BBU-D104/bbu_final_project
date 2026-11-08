from fastapi import APIRouter, Depends
from fastapi_cache import FastAPICache
from sqlmodel import Session

from app.crud.user.user import change_password, update_profile
from app.schemas.user.user import PasswordChange, ProfileRead, ProfileUpdate
from app.security import get_current_user
from database import get_session

router = APIRouter(prefix="/profile", tags=["profile"])

USERS_CACHE_NS = "users"


@router.put("/me", response_model=ProfileRead)
async def update_my_profile(
    profile: ProfileUpdate,
    session: Session = Depends(get_session),
    current_user=Depends(get_current_user),
):
    result = update_profile(session, current_user, profile)
    await FastAPICache.clear(namespace=USERS_CACHE_NS)
    return result


@router.post("/change-password/")
async def change_my_password(
    passwords: PasswordChange,
    session: Session = Depends(get_session),
    current_user=Depends(get_current_user),
):
    return change_password(session, current_user, passwords)
