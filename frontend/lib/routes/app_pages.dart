import 'package:frontend/binding/audit_logs_binding.dart';
import 'package:frontend/binding/category_binding.dart';
import 'package:frontend/binding/customer_binding.dart';
import 'package:frontend/binding/home_binding.dart';
import 'package:frontend/binding/payment_binding.dart';
import 'package:frontend/binding/product_binding.dart';
import 'package:frontend/binding/purchase_binding.dart';
import 'package:frontend/binding/role_binding.dart';
import 'package:frontend/binding/sale_binding.dart';
import 'package:frontend/binding/stock_adjustment_binding.dart';
import 'package:frontend/binding/stock_movement_binding.dart';
import 'package:frontend/binding/stock_transfer_binding.dart';
import 'package:frontend/binding/supplier_binding.dart';
import 'package:frontend/binding/user_binding.dart';
import 'package:frontend/binding/warehouse_binding.dart';
import 'package:frontend/screen/audit_logs/audit_logs_screen.dart';
import 'package:frontend/screen/audit_logs/widget/audit_log_detail_widget.dart';
import 'package:frontend/screen/category/category_screen.dart';
import 'package:frontend/screen/customer/customer_screen.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/payment/sale_with_payment/sale_with_payment_screen.dart';
import 'package:frontend/screen/product/product_screen.dart';
import 'package:frontend/screen/product/widget/add_product_widget.dart';
import 'package:frontend/screen/product/widget/edit_product_widget.dart';
import 'package:frontend/screen/product/widget/product_card_detail_widget.dart';
import 'package:frontend/screen/purchases/purchases_screen.dart';
import 'package:frontend/screen/purchases/widget/purchase_detail_widget.dart';
import 'package:frontend/screen/role/role_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/stock_adjustment_screen.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_detail_widget.dart';
import 'package:frontend/screen/stock/stock_movement/stock_movementscreen.dart';
import 'package:frontend/screen/stock/stock_transfer/stock_transfer_screen.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_detail_card_widget.dart';
import 'package:frontend/screen/stock/warehouse/warehouse_screen.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/supplier/widgets/supplier_detail_card_widget.dart';
import 'package:frontend/screen/user/user_screen.dart';
import 'package:frontend/screen/user/widget/user_detail_card_widget.dart';
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
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
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
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: AppRoutes.supplier,
      page: () => SupplierScreen(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: AppRoutes.customer,
      page: () => CustomerScreen(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.stockMovement,
      page: () => StockMovementscreen(),
      binding: StockMovementBinding(),
    ),
    GetPage(
      name: AppRoutes.stockAdjustment,
      page: () => StockAdjustmentScreen(),
      binding: StockAdjustmentBinding(),
    ),
    GetPage(
      name: AppRoutes.stockTransfer,
      page: () => StockTransferScreen(),
      binding: StockTransferBinding(),
    ),
    GetPage(
      name: AppRoutes.sale,
      page: () => SaleScreen(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: AppRoutes.saleList,
      page: () => SaleListScreen(),
    ),
    GetPage(
      name: AppRoutes.salePayment,
      page: () => PaymentScreen(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.role,
      page: () => RoleScreen(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => UserScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.warehouse,
      page: () => WarehouseScreen(),
      binding: WarehouseBinding(),
    ),
    GetPage(
      name: AppRoutes.auditLogs,
      page: () => AuditLogsScreen(),
      binding: AuditLogsBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductWidget(),
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => EditProductWidget(),
    ),
    GetPage(
      name: AppRoutes.currentSale,
      page: () => CurrentSaleWidget(),
    ),
    GetPage(
      name: AppRoutes.saleWithPayment,
      page: () => SaleWithPaymentScreen(),
    ),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: () => PaymentSuccessWidget(),
    ),

    GetPage(
      name: AppRoutes.productCardDetail,
      page: () => ProductCardDetailWidget(),
    ),
    GetPage(
      name: AppRoutes.purchaseDetail,
      page: () => PurchaseDetailWidget(),
    ),
    GetPage(
      name: AppRoutes.supplierDetail,
      page: () => SupplierDetailCardWidget(),
    ),
    GetPage(
      name: AppRoutes.stockAdjustmentDetail,
      page: () => StockAdjustmentDetailWidget(),
    ),
    GetPage(
      name: AppRoutes.stockTransferDetail,
      page: () => StockDetailCardWidget(),
    ),
    GetPage(
      name: AppRoutes.saleListDetail,
      page: () => SaleListDetailWidget(),
    ),
    GetPage(
      name: AppRoutes.userDetail,
      page: () => UserDetailCardWidget(),
    ),
    GetPage(
      name: AppRoutes.auditLogDetail,
      page: () => AuditLogDetailWidget(),
    ),
  ];
}
  