from fastapi import APIRouter, Depends
from sqlmodel import Session

from database import get_session
from app.schemas.auth import LoginRequest
from app.services.auth_service import login

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


@router.post("/login/")
def login_user(
    request: LoginRequest,
    session: Session = Depends(get_session),
):
    return login(request, session)