from pydantic import BaseModel

class TelegramRequest(BaseModel):
    title: str
    message: str