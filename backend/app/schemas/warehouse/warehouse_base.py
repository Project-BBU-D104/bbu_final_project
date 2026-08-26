from sqlmodel import SQLModel
from typing import Optional

class WarehouseSimple(SQLModel):
    id: Optional[int] = None
    name: str