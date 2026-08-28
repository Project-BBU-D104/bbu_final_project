from .users.users import router as users_router
from .category.category import router as category_router
from .product.product import router as product_router
from .supplier.supplier import router as supplier_router
from .customer.customer import router as customer_router
from .role.role import router as role_router
from .audit_logs.audit_logs import router as audit_logs_router
from .warehouse.warehouse import router as warehouse_router
from .warehouse.warehouse_stock import router as warehouse_stock_router
from .stock.stock_adjustment import router as stock_adjustment_router
from .product_transfer.product_transfer import router as product_transfer_router
from .product_transfer.product_transfer_item import router as product_transfer_item_router
from .purchase.purchase import router as purchase_router
from .purchase.purchase_item import router as purchase_item_router
from .sale.sale import router as sale_router
from .sale.sale_payment import router as sale_payment_router
from .telegram.telegram_router import router as telegram_router
from .auth.auth import router as auth_router

from .currency.currency import router as currency_router
from .payment_type.payment_type import router as payment_type_router
from .unit.unit import router as unit_router

from .purchase.purchase_requests import router as purchase_requests_router
from .purchase.purchase_request_items import router as purchase_request_items_router
from .purchase.purchase_payment import router as purchase_payments_router

from .home.home import router as recent_purchase_router

__all__ = ["users_router",category_router,product_router,supplier_router,customer_router,role_router,audit_logs_router,warehouse_router,warehouse_stock_router,stock_adjustment_router, product_transfer_router,purchase_router,purchase_item_router, sale_router, sale_payment_router,telegram_router, auth_router, currency_router, payment_type_router, unit_router, purchase_requests_router, purchase_request_items_router, purchase_payments_router,product_transfer_item_router,recent_purchase_router]