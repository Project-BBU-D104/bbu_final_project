# Inventory Management System

This project is an inventory management system for managing products, categories, suppliers, customers, stock, sales, purchases, payments, users, roles, and warehouses.

It has two parts:

- `backend/` — A FastAPI backend that provides the API and stores data in SQLite.
- `frontend/` — A Flutter mobile/web interface that uses the backend API.

## Main technologies

- **Backend:** Python, FastAPI, SQLModel, SQLite
- **Frontend:** Flutter, Dart, GetX
- **Default language:** Khmer

## Project structure

```text
Final Project/
├── backend/       # FastAPI API and database
└── frontend/      # Flutter application
```

## How to run the backend

Open a terminal in the `backend` folder:

```powershell
.venv\Scripts\activate
pip install -r requiment.txt
uvicorn main:app --reload
```

The backend will run at `http://127.0.0.1:8000`.

API documentation is available at:

- `http://127.0.0.1:8000/docs`
- `http://127.0.0.1:8000/redoc`

## How to run the frontend

Open another terminal in the `frontend` folder:

```bash
flutter pub get
flutter run
```

The frontend uses the API URL in `frontend/assets/.env`:

```text
API_URL=http://127.0.0.1:8000
```

Make sure the backend is running before using the frontend.

## Notes

- The SQLite database file is created when the backend runs.
- The frontend starts with Khmer as the default locale.
- This project is intended for learning and continued development.
