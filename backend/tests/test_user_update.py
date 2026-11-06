from app.crud.user.user import get_user, update_user
from app.models.role import Role
from app.models.user import User
from app.schemas.user.user import UserCreate
from app.security import hash_password, verify_password


def make_user(session):
    role = Role(name="Admin", description="", is_active=True)
    session.add(role)
    session.commit()
    session.refresh(role)

    user = User(
        name="admin",
        email="admin@example.com",
        password=hash_password("secret"),
        role_id=role.id,
        phone="012345678",
        photo="",
        is_active=True,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def update_payload(user, password):
    return UserCreate(
        name=user.name,
        email="new@example.com",
        password=password,
        is_active=True,
        role_id=user.role_id,
        phone="099999999",
        photo="",
    )


def test_blank_password_keeps_stored_hash(session):
    user = make_user(session)

    update_user(session, user.id, update_payload(user, password=""))

    stored = get_user(session, user.id)
    assert stored.email == "new@example.com"
    assert verify_password("secret", stored.password)


def test_non_blank_password_is_replaced(session):
    user = make_user(session)

    update_user(session, user.id, update_payload(user, password="changed"))

    stored = get_user(session, user.id)
    assert verify_password("changed", stored.password)
    assert not verify_password("secret", stored.password)