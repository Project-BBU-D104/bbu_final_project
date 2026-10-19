from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_payment import PurchasePayment
from app.schemas.purchase.purchase_payment import PurchasePaymentCreate, PurchasePaymentUpdate
from datetime import datetime, timezone
from decimal import Decimal
from app.models.purchase import Purchase

def get_completed_purchase_payment_total(session: Session, purchase_id: int) -> Decimal:
    payments = session.exec(
        select(PurchasePayment).where(
            PurchasePayment.purchase_id == purchase_id,
        )
    ).all()

    return sum(
        (
            Decimal(str(payment.amount))
            for payment in payments
            if (payment.status or "").strip().lower() == "completed"
        ),
        Decimal("0"),
    )


def calculate_purchase_payment(
    session: Session,
    purchase_id: int,
):
    purchase = session.get(Purchase, purchase_id)

    if not purchase:
        raise HTTPException(
            status_code=404,
            detail="Purchase not found."
        )

    # Include the amount paid when the purchase was created plus later payments.
    paid_amount = (
        Decimal(str(purchase.initial_paid_amount or 0))
        + get_completed_purchase_payment_total(session, purchase_id)
    )

    total_amount = Decimal(str(purchase.total_amount))

    # Calculate due amount
    due_amount = max(
        total_amount - paid_amount,
        Decimal("0"),
    )

    # Update purchase
    purchase.paid_amount = paid_amount
    purchase.due_amount = due_amount

    if paid_amount <= 0:
        purchase.payment_status = "unpaid"
    elif paid_amount >= total_amount:
        purchase.payment_status = "paid"
    else:
        purchase.payment_status = "partial"

    purchase.updated_at = datetime.now(timezone.utc)

    session.add(purchase)


def generate_payment_no(session: Session) -> str:
    last_payment = session.exec(
        select(PurchasePayment)
        .order_by(PurchasePayment.id.desc())
    ).first()

    if last_payment is None:
        return "PY001"

    try:
        last_number = int(
            last_payment.payment_no.removeprefix("PY")
        )
    except (ValueError, AttributeError):
        last_number = last_payment.id

    return f"PY{last_number + 1:03d}"


def create_purchase_payment(
    session: Session,
    purchase_payment: PurchasePaymentCreate,
):
    purchase = session.get(
        Purchase,
        purchase_payment.purchase_id,
    )

    if not purchase:
        raise HTTPException(
            status_code=404,
            detail="Purchase not found."
        )

     # Generate payment number automatically
    payment_data = purchase_payment.model_dump(
        exclude_none=True,
        exclude={"payment_no"},
    )

    payment_data["payment_no"] = generate_payment_no(session)

    db_payment = PurchasePayment(**payment_data)

    session.add(db_payment)
    session.flush()

    # Calculate purchase payment totals
    calculate_purchase_payment(
        session,
        purchase_payment.purchase_id,
    )

    session.commit()
    session.refresh(db_payment)

    return db_payment

def get_all_purchase_payment(session: Session):
    return session.exec(select(PurchasePayment)).all()

def get_purchase_payment(session: Session, purchase_payment_id: int):
    return session.get(PurchasePayment, purchase_payment_id)

def update_purchase_payment(session: Session, purchase_payment_id: int, purchase_payment: PurchasePaymentUpdate):
    db_purchase_payment = session.get(PurchasePayment, purchase_payment_id)
    if not db_purchase_payment:
        raise HTTPException(
            status_code=404,
            detail="Purchase Payment not found."
        )
    
    old_purchase_id = db_purchase_payment.purchase_id

    if purchase_payment.payment_no is not None:
        db_purchase_payment.payment_no = purchase_payment.payment_no
    if purchase_payment.purchase_id is not None:
        db_purchase_payment.purchase_id = purchase_payment.purchase_id
    if purchase_payment.supplier_id is not None:
        db_purchase_payment.supplier_id = purchase_payment.supplier_id
    if purchase_payment.payment_type_id is not None:
        db_purchase_payment.payment_type_id = purchase_payment.payment_type_id
    if purchase_payment.currency_id is not None:
        db_purchase_payment.currency_id = purchase_payment.currency_id
    if purchase_payment.amount is not None:
        db_purchase_payment.amount = purchase_payment.amount
    if purchase_payment.payment_date is not None:
        db_purchase_payment.payment_date = purchase_payment.payment_date
    if purchase_payment.note is not None:
        db_purchase_payment.note = purchase_payment.note
    if purchase_payment.status is not None:
        db_purchase_payment.status = purchase_payment.status

    db_purchase_payment.updated_at = datetime.now(timezone.utc)
    session.add(db_purchase_payment)
    session.flush()

    calculate_purchase_payment(session, old_purchase_id)
    if db_purchase_payment.purchase_id != old_purchase_id:
        calculate_purchase_payment(session, db_purchase_payment.purchase_id)

    session.commit()
    session.refresh(db_purchase_payment)
    return db_purchase_payment

def delete_purchase_payment(session: Session, purchase_payment_id: int):
    if not session.get(PurchasePayment, purchase_payment_id):
        raise HTTPException(
            status_code=404,
            detail="Purchase Payment not found."
        )
    
    purchase_payment = session.get(PurchasePayment, purchase_payment_id)

    if purchase_payment:
        purchase_id = purchase_payment.purchase_id
        session.delete(purchase_payment)
        session.flush()
        calculate_purchase_payment(session, purchase_id)
        session.commit()
    return {
        "message": "Purchase Payment deleted successfully",
        "purchase_payment": purchase_payment
    }