from fastapi import HTTPException
from sqlmodel import Session, select

from app.models.user import User
from app.schemas.auth.auth import LoginRequest
from app.security import verify_password, create_access_token


def login(request: LoginRequest, session: Session):

    user = session.exec(
        select(User).where(
            User.name.collate("utf8mb4_bin") == request.name
        )
    ).first()

    # User not found
    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid name or password",
        )

    # Verify password
    if not verify_password(
        request.password,
        user.password,
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid name or password",
        )

    # Create access token
    token = create_access_token(
        {
            "sub": str(user.id)
        }
    )

    print(f"User {user.name} logged in successfully. Token: {token}")

    # Return login response
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role.name,
            "phone": user.phone,
            "photo": user.photo
        },
    }