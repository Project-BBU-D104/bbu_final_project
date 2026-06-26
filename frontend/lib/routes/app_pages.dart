import 'package:frontend/binding/category_binding.dart';
import 'package:frontend/binding/customer_binding.dart';
import 'package:frontend/binding/product_binding.dart';
import 'package:frontend/screen/category/category_screen.dart';
import 'package:frontend/screen/customer/customer_screen.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/product/product_screen.dart';
import 'package:frontend/screen/product/widget/add_product_widget.dart';
import 'package:frontend/screen/purchases/purchases_screen.dart';
import 'package:frontend/screen/role/role_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/stock/stock_adjustment/stock_adjustment_screen.dart';
import 'package:frontend/screen/stock/stock_movement/stock_movementscreen.dart';
import 'package:frontend/screen/stock/stock_transfer/stock_transfer_screen.dart';
import 'package:frontend/screen/stock/warehouse/warehouse_screen.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/user/user_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

//file import controller
import 'package:frontend/controllers/landing_controller.dart';

import 'package:frontend/screen/auth/login_screen.dart';
import 'package:frontend/screen/home/home_screen.dart';
import 'package:frontend/screen/landing.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingScreen(),
      binding: BindingsBuilder(() {
        Get.put(LandingController());
      }),
    
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => CategoryScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => ProductScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.purchase,
      page: () => PurchasesScreen(),
      // bindings: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.supplier,
      page: () =>   SupplierScreen(),
    ),
    GetPage(
      name: AppRoutes.customer,
      page: () => CustomerScreen(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.stockMovement,
      page: () => StockMovementscreen(),
    ),
    GetPage(
      name: AppRoutes.stockAdjustment,
      page: () => StockAdjustmentScreen(),
    ),
    GetPage(
      name: AppRoutes.stockTransfer,
      page: () => StockTransferScreen(),
    ),
    GetPage(
      name: AppRoutes.sale,
      page: () => SaleScreen(),
    ),
    GetPage(
      name: AppRoutes.saleList,
      page: () => SaleListScreen(),
    ),
    GetPage(
      name: AppRoutes.salePayment,
      page: () => PaymentScreen(),
    ),
    GetPage(
      name: AppRoutes.role,
      page: () => RoleScreen(),
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => UserScreen(),
    ),
    GetPage(
      name: AppRoutes.warehouse,
      page: () => WarehouseScreen(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductWidget(),
    ),
  ];
}
