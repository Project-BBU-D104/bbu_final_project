from sqlmodel import Session, select
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload

def create_product(session: Session, product: ProductCreate):
    db_product = Product.model_validate(product)
    session.add(db_product)
    session.commit()
    session.refresh(db_product)
    return db_product

def get_all_product(session: Session):
    statement = (
        select(Product)
        .options(
            selectinload(Product.category),
            selectinload(Product.supplier)
        )
    )
    return session.exec(statement).all()

def get_product(session: Session, product_id: int):
    statement = (
        select(Product)
        .where(Product.id == product_id)
        .options(
            selectinload(Product.category),
            selectinload(Product.supplier)
        )
    )
    return session.exec(statement).first()

def update_product(session: Session, product_id: int, product: ProductUpdate):
    db_product = session.get(Product, product_id)
    if db_product:
        if product.category_id is not None:
            db_product.category_id = product.category_id
        if product.supplier_id is not None:
            db_product.supplier_id = product.supplier_id
        if product.name is not None:
            db_product.name = product.name
        if product.barcode is not None:
            db_product.barcode = product.barcode
        if product.photo is not None:
            db_product.photo = product.photo
        if product.cost_price is not None:
            db_product.cost_price = product.cost_price
        if product.sale_price is not None:
            db_product.sale_price = product.sale_price
        if product.qty is not None:
            db_product.qty = product.qty
        if product.allow_insert_qty is not None:
            db_product.allow_insert_qty = product.allow_insert_qty
        if product.unit is not None:
            db_product.unit = product.unit
        if product.description is not None:
            db_product.description = product.description

        db_product.updated_at = product.updated_at or datetime.utcnow()
        session.add(db_product)
        session.commit()
        session.refresh(db_product)
    return db_product

def delete_product(session: Session, product_id: int):
    product = session.get(Product, product_id)
    if product:
        session.delete(product)
        session.commit()
    return product