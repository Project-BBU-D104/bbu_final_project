from datetime import datetime
from decimal import Decimal
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, PlainSerializer, model_validator

PositiveId = Annotated[int, Field(strict=True, gt=0)]
Money = Annotated[Decimal, PlainSerializer(lambda value: format(value, ".2f"), return_type=str, when_used="json")]


class CheckoutLine(BaseModel):
    model_config = ConfigDict(extra="forbid")
    product_id: PositiveId
    warehouse_id: PositiveId
    qty: PositiveId


class CheckoutCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    checkout_id: str = Field(pattern=r"^[0-9a-f]{32}$")
    customer_id: PositiveId
    payment_type_id: PositiveId
    expected_total: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    sale_items: list[CheckoutLine] = Field(min_length=1)

    @model_validator(mode="after")
    def unique_lines(self):
        if len({(r.product_id, r.warehouse_id) for r in self.sale_items}) != len(self.sale_items):
            raise ValueError("Duplicate product and warehouse")
        return self


class ReceiptLine(CheckoutLine):
    product_name: str
    sale_price: Money
    subtotal: Money


class CheckoutReceipt(BaseModel):
    checkout_id: str
    sale_id: int
    invoice_no: str
    customer: str
    payment_method: str
    payment_date: datetime
    reference_no: str
    subtotal: Money
    total: Money
    lines: list[ReceiptLine]
