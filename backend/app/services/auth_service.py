from fastapi import HTTPException
from sqlmodel import Session, select

from app.models.user import User
from app.schemas.auth import LoginRequest
from app.security import verify_password, create_access_token


def login(request: LoginRequest, session: Session):
    user = session.exec(
        select(User).where(
            User.name == request.name
        )
    ).first()

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid name or password",
        )

    if not verify_password(
        request.password,
        user.password,
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid name or password",
        )

    token = create_access_token(
        {
            "sub": str(user.id)
        }
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
        },
    }