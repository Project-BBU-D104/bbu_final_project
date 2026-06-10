from sqlmodel import Session, select
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryUpdate
from datetime import datetime

def create_category(session: Session, category: CategoryCreate):
    db_category = Category.from_orm(category)
    session.add(db_category)
    session.commit()
    session.refresh(db_category)
    return db_category

def get_all_category(session: Session):
    return session.exec(select(Category)).all()

def get_category(session: Session, category_id: int):
    return session.get(Category, category_id)

def update_category(session: Session, category_id: int, category: CategoryUpdate):
    db_category = session.get(Category, category_id)
    if db_category:
        if category.name is not None:
            db_category.name = category.name
        if category.description is not None:
            db_category.description = category.description

        db_category.updated_at = category.updated_at or datetime.utcnow()
        session.add(db_category)
        session.commit()
        session.refresh(db_category)
    return db_category

def delete_category(session: Session, category_id: int):
    category = session.get(Category, category_id)
    if category:
        session.delete(category)
        session.commit()
    return category