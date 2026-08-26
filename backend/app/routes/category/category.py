from fastapi import APIRouter, Depends
from sqlmodel import Session
from database import get_session
from app.schemas.category.category import CategoryCreate, CategoryRead, CategoryUpdate
from app.crud.category.category import  create_category, get_all_category, get_category, update_category, delete_category

router = APIRouter(prefix="/category", tags=["category"])

@router.post("/", response_model=CategoryRead)
def create_new_category(category: CategoryCreate, session: Session = Depends(get_session)):
    return create_category(session, category)

@router.get("/", response_model=list[CategoryRead])
def read_all_category(session: Session = Depends(get_session)):
    return get_all_category(session)

@router.get("/{category_id}", response_model=CategoryRead)
def read_category(category_id: int, session: Session = Depends(get_session)):
    return get_category(session, category_id)

@router.put("/{category_id}", response_model=CategoryRead)
def update_category_route(category_id: int, category: CategoryUpdate, session: Session = Depends(get_session)):
    return update_category(session, category_id, category)

@router.delete("/{category_id}")
def delete_category_route(category_id: int, session: Session = Depends(get_session)):
    return delete_category(session, category_id)