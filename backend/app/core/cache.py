import hashlib
import json
from typing import Any, Callable, Dict, Optional, Tuple

from starlette.requests import Request
from starlette.responses import Response

from fastapi_cache.coder import JsonCoder


def _orm_to_dict(value: Any) -> Any:
    """Convert SQLModel/SQLAlchemy objects (with loaded relationships) to dicts.

    fastapi_cache's default JsonCoder uses jsonable_encoder, which does not
    include SQLAlchemy relationship attributes (e.g. User.role). The cached
    payload then fails `response_model` validation on a cache hit.
    """
    if isinstance(value, list):
        return [_orm_to_dict(item) for item in value]
    if isinstance(value, tuple):
        return tuple(_orm_to_dict(item) for item in value)
    if isinstance(value, dict):
        return {key: _orm_to_dict(item) for key, item in value.items()}
    if getattr(value, "_sa_instance_state", None) is not None:
        return {
            key: _orm_to_dict(item)
            for key, item in vars(value).items()
            if not key.startswith("_sa")
        }
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