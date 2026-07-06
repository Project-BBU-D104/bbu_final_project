from .users import router as users_router
from .category import router as category_router
from .product import router as product_router
from .supplier import router as supplier_router
from .customer import router as customer_router
from .role import router as role_router
from .audit_logs import router as audit_logs_router

__all__ = ["users_router",category_router,product_router,supplier_router,customer_router,role_router,audit_logs_router]