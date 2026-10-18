from fastapi import HTTPException
from sqlmodel import Session, select
from app.models.purchase_requests import PurchaseRequest
from app.models.purchase_request_items import PurchaseRequestItems
from app.schemas.purchase.purchase_requests import PurchaseRequestCreate, PurchaseRequestUpdate
from datetime import datetime, timezone

def generate_request_no(session: Session) -> str:
    # Get the latest request no
    last_request = session.exec(
        select(PurchaseRequest).order_by(PurchaseRequest.id.desc())
    ).first()

    if last_request is None:
        return "PR001"
 
    try:
        last_number = int(last_request.request_no.replace("PR", ""))
    except:
        last_number = last_request.id

    return f"PR{last_number + 1:03d}"

def create_purchase_request(
    session: Session,
    purchase_request: PurchaseRequestCreate,
):
    request_data = purchase_request.model_dump(
        exclude_none=True,
        exclude={"request_no"},
    )

    request_data["request_no"] = generate_request_no(session)

    db_purchase_request = PurchaseRequest(**request_data)

    session.add(db_purchase_request)
    session.commit()
    session.refresh(db_purchase_request)

    return db_purchase_request

def get_all_purchase_request(session: Session):
    return session.exec(select(PurchaseRequest)).all()

def get_purchase_request(session: Session, purchase_request_id: int):
    purchase_request = session.get(PurchaseRequest, purchase_request_id)
    if not purchase_request:
        raise HTTPException(status_code=404, detail="Purchase Request not found.")
    return purchase_request

def update_purchase_request(session: Session, purchase_request_id: int, purchase_request: PurchaseRequestUpdate):
    db_purchase_request = get_purchase_request(session, purchase_request_id)
    request_data = purchase_request.model_dump(exclude_unset=True, exclude_none=True)
    for field, value in request_data.items():
        setattr(db_purchase_request, field, value)

    db_purchase_request.updated_at = datetime.now(timezone.utc)
    session.add(db_purchase_request)
    session.commit()
    session.refresh(db_purchase_request)
    return db_purchase_request

def delete_purchase_request(session: Session, purchase_request_id: int):
    purchase_request = get_purchase_request(session, purchase_request_id)
    request_items = session.exec(
        select(PurchaseRequestItems).where(
            PurchaseRequestItems.purchase_request_id == purchase_request_id
        )
    ).all()
    for item in request_items:
        session.delete(item)
    session.delete(purchase_request)
    session.commit()
    return {
        "message": "Purchase Request deleted successfully",
        "purchase_request": purchase_request
    }