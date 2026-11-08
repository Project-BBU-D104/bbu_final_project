import asyncio
from datetime import datetime, timezone

import pytest
from fastapi import FastAPI, HTTPException
from pydantic import ValidationError

from app.models.role import Role
from app.models.user import User
from app.routes.profile import profile as profile_routes
from app.routes.profile.profile import router as profile_router
from app.schemas.user.user import PasswordChange, ProfileUpdate
from app.security import get_current_user, hash_password, verify_password


def make_cashier(session, password="secret123"):
    role = Role(name="Cashier", description="", is_active=True)
    session.add(role)
    session.commit()
    session.refresh(role)

    user = User(
        name="Cashier",
        email="cashier@example.com",
        password=hash_password(password),
        role_id=role.id,
        phone="010000000",
        photo="old.png",
        is_active=True,
        updated_at=datetime(2020, 1, 1, tzinfo=timezone.utc),
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


@pytest.fixture
def cashier(session):
    return make_cashier(session)


@pytest.fixture
def cleared_namespaces(monkeypatch):
    calls = []

    async def fake_clear(namespace=None):
        calls.append(namespace)

    monkeypatch.setattr(profile_routes.FastAPICache, "clear", fake_clear)
    return calls


def test_self_update_changes_only_profile_fields(
    session, cashier, cleared_namespaces
):
    original_role_id = cashier.role_id
    original_updated_at = cashier.updated_at

    # Extra privileged fields are accepted as input but ignored by the schema.
    profile = ProfileUpdate.model_validate(
        {
            "name": "  Updated Name  ",
            "email": "new@example.com",
            "phone": "099999999",
            "photo": "new.png",
            "role_id": 999,
            "is_active": False,
        }
    )
    assert profile.model_dump().keys() == {"name", "email", "phone", "photo"}

    result = asyncio.run(
        profile_routes.update_my_profile(
            profile,
            session=session,
            current_user=cashier,
        )
    )

    assert result.name == "Updated Name"
    assert result.email == "new@example.com"
    assert result.phone == "099999999"
    assert result.photo == "new.png"

    stored = session.get(User, cashier.id)
    session.refresh(stored)
    assert stored.name == "Updated Name"
    assert stored.role_id == original_role_id
    assert stored.is_active is True
    assert stored.updated_at > original_updated_at
    assert cleared_namespaces == ["users"]


def test_self_update_rejects_blank_name(session, cashier):
    # FastAPI maps this ValidationError to HTTP 422.
    with pytest.raises(ValidationError):
        ProfileUpdate.model_validate(
            {
                "name": "   ",
                "email": "new@example.com",
                "phone": "",
                "photo": "",
            }
        )


def test_change_password_with_correct_current_password(session, cashier):
    result = asyncio.run(
        profile_routes.change_my_password(
            PasswordChange(
                current_password="secret123",
                new_password="newpass123",
            ),
            session=session,
            current_user=cashier,
        )
    )

    assert result["message"] == "Password changed successfully."
    stored = session.get(User, cashier.id)
    session.refresh(stored)
    assert verify_password("newpass123", stored.password)
    assert not verify_password("secret123", stored.password)


def test_change_password_with_wrong_current_password(session, cashier):
    session.refresh(cashier)
    original_hash = cashier.password

    with pytest.raises(HTTPException) as error:
        asyncio.run(
            profile_routes.change_my_password(
                PasswordChange(
                    current_password="wrong-password",
                    new_password="newpass123",
                ),
                session=session,
                current_user=cashier,
            )
        )

    assert error.value.status_code == 400
    assert error.value.detail == "Current password is incorrect"
    stored = session.get(User, cashier.id)
    session.refresh(stored)
    assert stored.password == original_hash


def test_change_password_rejects_short_new_password(session, cashier):
    # FastAPI maps this ValidationError to HTTP 422.
    with pytest.raises(ValidationError):
        PasswordChange(current_password="secret123", new_password="short")


def test_profile_routes_require_jwt_user_not_admin_role(session, cashier):
    app = FastAPI()
    app.include_router(profile_router)

    routes = {route.path: route for route in app.routes if hasattr(route, "path")}
    for path in ("/profile/me", "/profile/change-password/"):
        calls = [dependency.call for dependency in routes[path].dependant.dependencies]
        assert get_current_user in calls
