# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Inventory management system: `backend/` (FastAPI + SQLModel) and `frontend/` (Flutter + GetX). Coding style, commit, and PR conventions are in `AGENTS.md`. Default UI language is Khmer.

Any plan you write down must be saved in the repository root (`Final Project/`), never inside `backend/`, `frontend/`, or any other subdirectory.

Never Push code to Github or similar without asking the user.

Never add `Co-Authored-By` trailers to commit messages. 

## Commands

Backend (from `backend/`, with `.venv` activated):

```bash
python -m uvicorn main:app --reload        # dev server on :8000, docs at /docs
python -m alembic upgrade head             # apply migrations
python -m alembic revision --autogenerate -m "describe change"   # review before applying
python -m app.seeders.create_admin_user    # seed admin (idempotent by email)
python -m app.seeders.create_default_data  # seed default data (idempotent by name)
python -m pytest tests/                    # backend tests
python -m pytest tests/test_product_warehouse.py            # single test file
python -m pytest tests/test_product_warehouse.py::test_name # single test
```

Frontend (from `frontend/`):

```bash
flutter pub get
flutter run          # API_URL comes from frontend/assets/.env
flutter test         # Dart tests live in frontend/test/ (*_test.dart)
flutter test test/some_test.dart --plain-name "test name"   # single test
flutter analyze
```

## Backend architecture

- **Config**: `backend/.env` supplies `DATABASE_URL` (MySQL via PyMySQL; engine in `database.py` tunes pool recycling for it), `SECRET_KEY`, `SQL_ECHO`. Alembic reads the same env var in `alembic/env.py` — the URL in `alembic.ini` is a placeholder.
- **Layering**: `app/routes/<domain>/` (HTTP only) → `app/crud/<domain>/` (queries, take a `Session`) → `app/models/` (SQLModel table classes) + `app/schemas/<domain>/` (`XCreate`/`XUpdate`/`XRead` pydantic models). Adding an endpoint means touching routes, its `app/routes/__init__.py` re-export, and registration in `main.py`.
- **Caching**: fastapi-cache2 in-memory, initialized in `main.py` lifespan with a custom key builder and `ORMJsonCoder` from `app/core/cache.py`. Pattern per router: GETs use `@cache(namespace=CACHE_NS, expire=...)`; every mutation calls `await FastAPICache.clear(namespace=CACHE_NS)` before returning. Mutations that change stock quantities (purchase, sale, transfer, adjustment, warehouse_stock) must also `await clear_stock_caches()` — it clears the `warehouse` and `product` namespaces whose payloads embed stock. Follow this when adding routes or stale reads will occur.
- **Auth**: JWT bearer in `app/security.py`. `get_current_user` decodes the token and loads the user with its role; `require_roles("Admin", ...)` gates by role name. Admin-only routers are gated wholesale via `dependencies=[Depends(require_roles("Admin"))]` in `main.py`.
- **Tests**: `backend/tests/conftest.py` builds an in-memory SQLite DB from `SQLModel.metadata` (importing `app.models` registers all tables) and provides `session` and `seed` fixtures. Tests bypass HTTP and call crud/service functions directly.

## Frontend architecture

- GetX for state and navigation: controllers in `lib/controllers/`, screens in `lib/screen/`, routes/bindings in `lib/routes/` and `lib/binding/`.
- API access goes through `lib/services/` (e.g. `api_service.dart`); `API_URL` and Telegram keys load from `assets/.env` via flutter_dotenv.
- `lib/locator.dart` wires get_it singletons (storage, Telegram) at startup.
- Localization strings live in `lib/localization/`; shared theme in `lib/themes/`.

## Gotchas

- CORS is wide open (`allow_origins=["*"]` in `main.py`) — fine for dev, must not ship to production.
- `verify_password` in `app/security.py` falls back to plain-text comparison for legacy stored passwords.
- The cache is in-memory per process: multiple uvicorn workers each hold their own cache, and invalidation does not cross processes.
- `SQLAlchemy==2.0.45` is pinned on purpose: 2.1.x compiled extensions (`_processors_cy`) are blocked by Windows App Control on some machines. Do not upgrade it casually.
