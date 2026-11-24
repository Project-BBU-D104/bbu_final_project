import hashlib
import json
from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

from app.crud.sale.sale import _stage_sale
from app.crud.sale.sale_payment import _stage_sale_payment
from app.models import Checkout, Customer, PaymentType
from app.schemas.sale.checkout import CheckoutCreate, CheckoutReceipt, ReceiptLine
from app.schemas.sale.sale import SaleCreate
from app.schemas.sale.sale_payment import SalePaymentCreate


def checkout_sale(session: Session, request: CheckoutCreate, user_id: int) -> CheckoutReceipt:
    lines = sorted(request.sale_items, key=lambda r: (r.product_id, r.warehouse_id))
    items = [line.model_dump() for line in lines]
    canonical = request.model_dump(mode="json") | {
        "sale_items": items, "expected_total": format(request.expected_total, ".2f"),
    }
    digest = hashlib.sha256(json.dumps(canonical, sort_keys=True).encode()).hexdigest()
    claim = Checkout(checkout_id=request.checkout_id, user_id=user_id, request_hash=digest)
    try:
        session.add(claim)
        try:
            session.flush()
        except IntegrityError as err:
            session.rollback()
            if (err.orig.args[0] != 1062 and
                    getattr(err.orig, "sqlite_errorname", "") != "SQLITE_CONSTRAINT_PRIMARYKEY"):
                raise
            original = session.get(Checkout, request.checkout_id)
            if original is None:
                raise
            if original.user_id != user_id or original.request_hash != digest:
                raise HTTPException(409, "Checkout ID conflicts with an existing request.")
            return CheckoutReceipt.model_validate(original.receipt)

        customer = session.get(Customer, request.customer_id)
        method = session.get(PaymentType, request.payment_type_id)
        if customer is None:
            raise HTTPException(400, "Selected customer no longer exists.")
        if method is None or not method.status:
            raise HTTPException(400, "Selected payment type is unavailable.")
        now = datetime.now(timezone.utc)
        sale = _stage_sale(session, SaleCreate(
            user_id=user_id, customer_id=customer.id, payment_method=method.name,
            invoice_no=request.checkout_id, sale_items=items, sale_date=now, status="completed",
        ))
        if sale.total_amount != request.expected_total:
            raise HTTPException(400, "Cart prices have changed. Review the updated total.")
        sale.invoice_no = f"POS-{sale.id}"
        payment = _stage_sale_payment(session, SalePaymentCreate(
            user_id=user_id, sale_id=sale.id, amount=sale.total_amount,
            payment_method=method.name, reference_no=request.checkout_id, payment_date=now,
            created_at=now, note="Sale payment",
        ))
        receipt = CheckoutReceipt(
            checkout_id=request.checkout_id, sale_id=sale.id, invoice_no=sale.invoice_no,
            customer=customer.name, payment_method=payment.payment_method,
            payment_date=payment.payment_date, reference_no=payment.reference_no,
            subtotal=sale.subtotal, total=sale.total_amount,
            lines=[ReceiptLine(product_id=r.product_id, warehouse_id=r.warehouse_id,
                               product_name=r.product.name, qty=r.qty, sale_price=r.sale_price,
                               subtotal=r.subtotal) for r in sale.sale_items],
        )
        claim.receipt = receipt.model_dump(mode="json")
        session.commit()
        return receipt
    except HTTPException as err:
        session.rollback()
        if err.status_code == 404:
            raise HTTPException(400, err.detail) from err
        raise
    except Exception:
        session.rollback()
        raise
