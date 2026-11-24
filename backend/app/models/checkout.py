from sqlalchemy import CHAR, JSON
from sqlmodel import Field, SQLModel


class Checkout(SQLModel, table=True):
    __tablename__ = "pos_checkouts"

    checkout_id: str = Field(primary_key=True, sa_type=CHAR(32))
    user_id: int
    request_hash: str = Field(sa_type=CHAR(64))
    receipt: dict | None = Field(default=None, sa_type=JSON(none_as_null=True))
