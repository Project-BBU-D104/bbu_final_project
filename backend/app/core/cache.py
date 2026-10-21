import hashlib
import json
from typing import Any, Callable, Dict, Optional, Tuple

from starlette.requests import Request
from starlette.responses import Response
from sqlalchemy import inspect as sa_inspect

from fastapi_cache.coder import JsonCoder


def _orm_columns(value: Any) -> Dict[str, Any]:
    """Return only an ORM object's column values (used to break cycles)."""
    state = sa_inspect(value)
    return {
        attr.key: _orm_to_dict(getattr(value, attr.key))
        for attr in state.mapper.column_attrs
    }


def _orm_to_dict(value: Any, _seen: Optional[frozenset] = None) -> Any:
    """Convert SQLModel/SQLAlchemy objects (with loaded relationships) to dicts.

    fastapi_cache's default JsonCoder uses jsonable_encoder, which does not
    include SQLAlchemy relationship attributes (e.g. User.role). The cached
    payload then fails `response_model` validation on a cache hit.

    Relationships can point back to a parent (e.g. Warehouse -> stock ->
    warehouse), so objects already on the current branch are serialized as
    columns only instead of recursing forever.
    """
    seen = _seen or frozenset()

    if isinstance(value, list):
        return [_orm_to_dict(item, seen) for item in value]
    if isinstance(value, tuple):
        return tuple(_orm_to_dict(item, seen) for item in value)
    if isinstance(value, dict):
        return {key: _orm_to_dict(item, seen) for key, item in value.items()}
    if getattr(value, "_sa_instance_state", None) is not None:
        if id(value) in seen:
            return _orm_columns(value)

        seen = seen | {id(value)}
        data = {
            key: _orm_to_dict(item, seen)
            for key, item in vars(value).items()
            if not key.startswith("_sa")
        }
        # Computed properties (e.g. Product.warehouse) live on the class, not in
        # __dict__, so the cached payload would otherwise lose them and a cache
        # hit would validate differently from a fresh response.
        for name, attr in type(value).__dict__.items():
            if isinstance(attr, property) and name not in data:
                data[name] = _orm_to_dict(getattr(value, name), seen)
        return data
    return value


class ORMJsonCoder(JsonCoder):
    @classmethod
    def encode(cls, value: Any) -> bytes:
        return super().encode(_orm_to_dict(value))


def cache_key_builder(
    func: Callable[..., Any],
    namespace: str = "",
    *,
    request: Optional[Request] = None,
    response: Optional[Response] = None,
    args: Tuple[Any, ...] = (),
    kwargs: Optional[Dict[str, Any]] = None,
) -> str:
    # Key on the URL only (session is in kwargs and changes every request).
    if request is not None:
        raw = f"{namespace}:{request.url.path}"
        if request.url.query:
            raw += f"?{request.url.query}"
    else:
        raw = f"{namespace}:{func.__name__}"
    return f"{namespace}:{hashlib.md5(raw.encode()).hexdigest()}"