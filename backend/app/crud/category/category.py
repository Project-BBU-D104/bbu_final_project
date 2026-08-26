from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.category import Category
from app.schemas.category.category import CategoryCreate, CategoryUpdate
from datetime import datetime

from app.services.telegram_service import send_message

def create_category(session: Session, category: CategoryCreate):
    existing = session.exec(
        select(Category).where(Category.name == category.name)
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Category name already exists."
        )
    
    db_category = Category.from_orm(category)
    session.add(db_category)
    session.commit()
    session.refresh(db_category)

    # Send Telegram Notification
    message = f"""
        <b>🛒 INVENTORY SYSTEM</b>

        <b>━━━━━━━━━━━━━━━━</b>

        📌 <b>Action:</b> New Category

        🆔 <b>ID:</b> {db_category.id}

        🏷 <b>Name:</b> {db_category.name}

        📝 <b>Description:</b>
        {db_category.description or "None"}

        📆 <b>Date:</b>
        {db_category.created_at.strftime("%d/%m/%Y %H:%M")}

        <b>━━━━━━━━━━━━━━━━</b>

        🤖 Sent by Inventory Bot
        """
    send_message(message)

    return db_category

def get_all_category(session: Session):
    return session.exec(select(Category)).all()

def get_category(session: Session, category_id: int):
    return session.get(Category, category_id)

def update_category(session: Session, category_id: int, category: CategoryUpdate):
    if not session.get(Category, category_id):
        raise HTTPException(
            status_code=404,
            detail="Category not found."
        )
    
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
    if not session.get(Category, category_id):
        raise HTTPException(
            status_code=404,
            detail="Category not found."
        )
    
    category = session.get(Category, category_id)

    if category:
        session.delete(category)
        session.commit()
    return {
        "message": "Category deleted successfully",
        "category": category
    }