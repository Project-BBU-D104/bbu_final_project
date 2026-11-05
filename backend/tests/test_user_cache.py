from fastapi import FastAPI
from fastapi.testclient import TestClient
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend

from app.core.cache import ORMJsonCoder, cache_key_builder
from app.models.role import Role
from app.models.user import User
from app.routes.users.users import router as users_router
from database import get_session


def make_user(session):
    role = Role(name="Admin", description="", is_active=True)
    session.add(role)
    session.commit()
    session.refresh(role)

    user = User(
        name="admin",
        email="admin@example.com",
        password="hash",
        role_id=role.id,
        phone="012345678",
        photo="",
        is_active=True,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def test_user_endpoint_returns_role_on_cache_hit(session):
    user = make_user(session)

    FastAPICache.init(
        InMemoryBackend(),
        prefix="test-cache",
        key_builder=cache_key_builder,
        coder=ORMJsonCoder,
        expire=60,
    )

    app = FastAPI()
    app.include_router(users_router)
    app.dependency_overrides[get_session] = lambda: session

    with TestClient(app) as client:
        first = client.get(f"/users/{user.id}")
        second = client.get(f"/users/{user.id}")

    assert first.status_code == 200, first.text
    assert second.status_code == 200, second.text
    assert second.json()["role"]["name"] == "Admin"
