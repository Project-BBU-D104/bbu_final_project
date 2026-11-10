# Repository Guidelines

Plans must be written to files in the repository root only. Never save plan or design documents inside `backend/`, `frontend/`, or any other subdirectory.

Never Push code to Github or similar without asking the user.

Never add Co-Authored-By trailers to commit messages.

Never Push or commit the Plan that generate by any Agent.

## Project Structure & Module Organization

This repository contains an inventory management system with two applications:

- `backend/` contains the FastAPI service. `main.py` registers routers; `app/routes/` exposes endpoints, `app/crud/` contains database operations, `app/models/` defines SQLModel entities, and `app/schemas/` defines API models. Database setup and migrations live in `database.py` and `alembic/`.
- `frontend/` contains the Flutter application. Screens are under `lib/screen/`, controllers under `lib/controllers/`, API clients under `lib/services/`, reusable UI under `lib/widget/`, and shared utilities under `lib/utils/`, `lib/themes/`, and `lib/localization/`. Assets are in `assets/`.
- Tests currently live in `frontend/test/`; platform-specific runner files are under `frontend/android/`, `ios/`, `macos/`, `linux/`, and `windows/`.

## Build, Test, and Development Commands

Backend, from `backend/` (activate `.venv` first):

```powershell
pip install -r requirements.txt
python -m uvicorn main:app --reload
python -m alembic upgrade head
```

Use `/docs` or `/redoc` to inspect the API. Create migrations with `alembic revision --autogenerate -m "describe change"` and review them before applying.

Frontend, from `frontend/`:

```bash
flutter pub get
flutter run
flutter test
flutter analyze
flutter build <platform>
```

Set the API endpoint in `frontend/assets/.env` before running the app.

## Coding Style & Naming Conventions

Use four spaces and PEP 8-style snake_case for Python modules, functions, and variables; use PascalCase for classes and FastAPI/SQLModel types. use lower_snake_case filenames, PascalCase widgets/classes, and camelCase members. Keep feature-specific code in its corresponding route/service/controller directory. Do not edit generated platform files unless the change is platform-specific.

When redesigning a screen, always use all supplier screens( mian, edit, create, and detail ) in `frontend/lib/screen/supplier/` as the reference for layout, styling, responsive behavior, and interactions, adapting them to the screen's needs.

## Testing Guidelines

Run `flutter test` for Dart tests and `flutter analyze` for static checks. Add tests under `frontend/test/` with `_test.dart` suffix, and cover new controllers, services, and user-visible behavior where practical. Backend tests are not currently present; new API behavior should add focused tests before merging.

## Commit & Pull Request Guidelines

Existing commits are short and inconsistent (for example, `update` and `add readme`). For new commits, use an imperative, specific subject such as `Add warehouse stock validation`, optionally prefixed by area (`backend:` or `frontend:`). Never add `Co-Authored-By` trailers to commit messages. Pull requests should explain the behavior change, list validation commands run, link an issue when applicable, and include screenshots or a short recording for UI changes. Call out migration, environment, or configuration changes explicitly.

## Security & Configuration

Never commit real credentials, tokens, or production connection details. Keep local values in environment files and verify wildcard CORS or development defaults are not used in production. Treat migrations and seeders as deployment-impacting changes.
