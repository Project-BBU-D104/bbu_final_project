from .users import router as users_router
from .category import router as category_router
from .product import router as product_router
from .supplier import router as supplier_router

__all__ = ["users_router",category_router,product_router,supplier_router]