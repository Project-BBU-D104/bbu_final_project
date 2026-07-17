from sqlmodel import Session, select
from app.models.purchase import Purchase
from app.schemas.purchase import PurchaseCreate, PurchaseUpdate
from datetime import datetime
from sqlalchemy.orm import selectinload
from fastapi import HTTPException
from app.models.purchase_item import PurchaseItem
from app.models.warehouse_stock import WarehouseStock
from app.crud.warehouse_stock import increase_stock

def generate_invoice_no(session: Session) -> str:
    # Get the latest purchase
    last_purchase = session.exec(
        select(Purchase).order_by(Purchase.id.desc())
    ).first()

    if last_purchase is None:
        return "INV001"

    # If previous invoice is INV001 -> number = 1
    try:
        last_number = int(last_purchase.invoice_no.replace("INV", ""))
    except:
        last_number = last_purchase.id

    return f"INV{last_number + 1:04d}"

def create_purchase(session: Session, purchase: PurchaseCreate):
    purchase_data = purchase.model_dump(exclude={"items"})

    if not purchase_data.get("invoice_no"):
        purchase_data["invoice_no"] = generate_invoice_no(session)

    db_purchase = Purchase(**purchase_data)

    session.add(db_purchase)

    # Insert purchase and get its ID
    session.flush()

    # Create purchase items
    for item in purchase.items:
        db_item = PurchaseItem(
            purchase_id=db_purchase.id,
            product_id=item.product_id,
            qty=item.qty,
            cost_price=item.cost_price,
            subtotal=item.subtotal,
        )

        session.add(db_item)

        increase_stock(
            session=session,
            warehouse_id=db_purchase.warehouse_id,
            product_id=item.product_id,
            qty=item.qty,
        )

    session.commit()

    session.refresh(db_purchase)

    return db_purchase

def get_all_purchases(session: Session):
    statement = (
        select(Purchase)
        .options(
            selectinload(Purchase.user),
            selectinload(Purchase.supplier),
            selectinload(Purchase.purchase_items)
            .selectinload(PurchaseItem.product)
        )
    )
    return session.exec(statement).all()

def get_purchase(session: Session, purchase_id: int):
    statement = (
        select(Purchase)
        .where(Purchase.id == purchase_id)
        .options(
            selectinload(Purchase.user),
            selectinload(Purchase.supplier)
        )
    )
    return session.exec(statement).first()

def update_purchase(session: Session, purchase_id: int, purchase: PurchaseUpdate):
    db_purchase = session.get(Purchase, purchase_id)
    if db_purchase:
        if purchase.supplier_id is not None:
            db_purchase.supplier_id = purchase.supplier_id
        if purchase.user_id is not None:
            db_purchase.user_id = purchase.user_id
        if purchase.invoice_no is not None:
            db_purchase.invoice_no = purchase.invoice_no
        if purchase.purchase_date is not None:
            db_purchase.purchase_date = purchase.purchase_date
        if purchase.subtotal is not None:
            db_purchase.subtotal = purchase.subtotal
        if purchase.tax_amount is not None:
            db_purchase.tax_amount = purchase.tax_amount
        if purchase.discount_amount is not None:
            db_purchase.discount_amount = purchase.discount_amount
        if purchase.total_amount is not None:
            db_purchase.total_amount = purchase.total_amount
        if purchase.paid_amount is not None:
            db_purchase.paid_amount = purchase.paid_amount
        if purchase.due_amount is not None:
            db_purchase.due_amount = purchase.due_amount
        if purchase.payment_status is not None:
            db_purchase.payment_status = purchase.payment_status
        if purchase.status is not None:
            db_purchase.status = purchase.status

        db_purchase.updated_at = purchase.updated_at or datetime.utcnow()
        session.add(db_purchase)
        session.commit()
        session.refresh(db_purchase)
    return db_purchase

def delete_purchase(session: Session, purchase_id: int):
    purchase = session.get(Purchase, purchase_id)

    if not purchase:
        raise HTTPException(status_code=404, detail="Purchase not found")
    
    # Reverse stock
    items = session.exec(
        select(PurchaseItem).where(PurchaseItem.purchase_id == purchase.id)
    ).all()

    for item in items:
        stock = session.exec(
            select(WarehouseStock).where(
                WarehouseStock.warehouse_id == purchase.warehouse_id,
                WarehouseStock.product_id == item.product_id
            )
        ).first()

        if stock:
            stock.qty -= item.qty

        # Delete purchase item
        session.delete(item)

    # Delete purchase
    session.delete(purchase)

    session.commit()

    return {"message": "Purchase deleted successfully"}