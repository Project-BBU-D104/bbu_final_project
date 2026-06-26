import 'package:frontend/binding/category_binding.dart';
import 'package:frontend/binding/product_binding.dart';
import 'package:frontend/screen/category/category_screen.dart';
import 'package:frontend/screen/product/product_screen.dart';
import 'package:frontend/screen/stock/stock_movement/stock_movementscreen.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
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
      name: AppRoutes.supplier,
      page: () =>   SupplierScreen(),
    ),
    GetPage(
      name: AppRoutes.stockMovement,
      page: () => StockMovementscreen(),
    ),
  ];
}
