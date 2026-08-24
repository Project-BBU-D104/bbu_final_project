from fastapi import APIRouter
from app.schemas.telegram import TelegramRequest
from app.services.telegram_service import send_message

router = APIRouter(
    prefix="/telegram",
    tags=["Telegram"]
)

@router.post("/send")
def telegram(req: TelegramRequest):

    text = f"""
📢 {req.title}

{req.message}
"""

    send_message(text)

    return {
        "success": True
    }