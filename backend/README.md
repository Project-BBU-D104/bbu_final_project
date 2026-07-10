# Backend Project

FastAPI-based backend application.

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

## Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd backend
```

### 2. Create a Virtual Environment
```bash
# On Windows
python -m venv .venv

# Activate virtual environment
.venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requiment.txt
```

## Running the Project

### Start the Development Server
```bash
uvicorn main:app --reload
```

This will start the server at `http://localhost:8000`

**Options:**
- `--reload`: Enable auto-restart on code changes (development only)
- `--host 0.0.0.0`: Make server accessible from other machines
- `--port 8000`: Specify port (default is 8000)

### Access the API
- **Main API**: http://localhost:8000
- **Swagger UI (Interactive Docs)**: http://localhost:8000/docs
- **ReDoc (API Documentation)**: http://localhost:8000/redoc

## Project Structure

```
backend/
├── main.py              # Main application entry point
├── requiment.txt        # Python dependencies
└── README.md            # This file
```

## Key Dependencies

- **FastAPI**: Modern web framework for building APIs
- **Uvicorn**: ASGI web server
- **Pydantic**: Data validation using Python type annotations
- **Starlette**: Lightweight ASGI framework (used by FastAPI)

## Troubleshooting

### Virtual Environment Issues
If you encounter issues with the virtual environment, try recreating it:
```bash
rm -r .venv  # or rmdir /s .venv on Windows
python -m venv .venv
.venv\Scripts\activate
pip install -r requiment.txt
```

### Port Already in Use
If port 8000 is already in use:
```bash
uvicorn main:app --port 8001 --reload
```

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Uvicorn Documentation](https://www.uvicorn.org/)
- [Pydantic Documentation](https://docs.pydantic.dev/)


## run migrate backend database
## create migrate

alembic revision --autogenerate -m "create categories table"

## commit migrate
alembic upgrade head