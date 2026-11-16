import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_detail_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'package:frontend/services/main_service/stock_adjustment_service.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'supplier_test_support.dart' show setUpSupplierTests;

void setUpAdjustmentTests() => setUpSupplierTests();

class AdjustmentWarehouseDouble extends WarehouseController {
  int refreshCalls = 0;
  // The production onInit starts API work; this double supplies local records.
  @override
  // ignore: must_call_super
  void onInit() {
    warehouseList.assignAll([
      {'id': 1, 'name': 'Main'},
    ]);
  }

  @override
  Future<void> getWarehouses() async {
    refreshCalls++;
  }
}

class AdjustmentProductDouble extends ProductController {
  int refreshCalls = 0;
  @override
  // ignore: must_call_super
  void onInit() {
    products.assignAll([
      {'id': 1, 'name': 'Rice'},
    ]);
  }

  @override
  Future<void> getProducts({bool showLoading = true}) async {
    refreshCalls++;
  }
}

void bindAdjustmentOptions() {
  Get.put<WarehouseController>(AdjustmentWarehouseDouble());
  Get.put<ProductController>(AdjustmentProductDouble());
}

class AdjustmentWarehouseStockDouble extends WarehouseStockController {
  int refreshCalls = 0;
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getWarehouseStock() async {
    refreshCalls++;
  }
}

Future<void> pumpAdjustmentHost(
  WidgetTester tester, {
  required Widget home,
  Size size = const Size(390, 844),
  bool dark = false,
  Locale locale = const Locale('en', 'US'),
  double textScale = 1,
  double keyboardInset = 0,
  bool shell = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslation(),
      locale: locale,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      defaultTransition: Transition.noTransition,
      initialRoute: AppRoutes.stockAdjustment,
      getPages: [
        GetPage(name: AppRoutes.stockAdjustment, page: () => home),
        GetPage(
          name: AppRoutes.stockAdjustmentDetail,
          page: () => StockAdjustmentDetailWidget(),
        ),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
          disableAnimations: true,
        ),
        child: shell
            ? DesktopAppShell(route: AppRoutes.stockAdjustment, child: child!)
            : child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}

Map<String, dynamic> adjustmentJson(
  int id, {
  String type = 'increase',
  int qty = 3,
  int previousQty = 7,
  int newQty = 10,
}) => {
  'id': id,
  'product_id': 1,
  'warehouse_id': 1,
  'product': {'id': 1, 'name': 'Rice'},
  'warehouse': {'id': 1, 'name': 'Main'},
  'user': null,
  'adjustment_type': type,
  'qty': qty,
  'previous_qty': previousQty,
  'new_qty': newQty,
  'reference_no': 'ADJ-$id',
  'reason': '',
  'created_at': 'invalid',
};

class FakeStockAdjustmentService extends StockAdjustmentService {
  List<Map<String, dynamic>> items = [adjustmentJson(1)];
  int createCalls = 0, updateCalls = 0, deleteCalls = 0;
  bool failGet = false, failWrite = false;
  Map<String, dynamic>? payload;
  Completer<void>? writeGate;
  Completer<dynamic>? listGate, editGate;
  @override
  Future<dynamic> getStockAdjustments() async {
    if (listGate != null) return listGate!.future;
    if (failGet) throw Exception('private server error');
    return List<Map<String, dynamic>>.from(items);
  }

  @override
  Future<dynamic> getStockAdjustmentById(int id) async => editGate == null
      ? items.firstWhere((e) => e['id'] == id)
      : editGate!.future;
  Future<dynamic> write(Map<String, dynamic> data, int id) async {
    payload = data;
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw Exception('private server error');
    final item = {...adjustmentJson(id), ...data};
    items = [...items.where((e) => e['id'] != id), item];
    return item;
  }

  @override
  Future<dynamic> createStockAdjustment(Map<String, dynamic> data) {
    createCalls++;
    return write(data, 2);
  }

  @override
  Future<dynamic> updateStockAdjustment(int id, Map<String, dynamic> data) {
    updateCalls++;
    return write(data, id);
  }

  @override
  Future<dynamic> deleteStockAdjustment(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('private server error');
    items.removeWhere((e) => e['id'] == id);
  }
}

class FakeAdjustmentStockService extends WarehouseStockService {
  int qty = 10, calls = 0;
  bool fail = false;
  final gates = <String, Completer<dynamic>>{};
  @override
  Future<dynamic> getProductStock({
    required int warehouseId,
    required int productId,
  }) async {
    calls++;
    if (fail) throw Exception('offline');
    return gates['$warehouseId/$productId']?.future ?? {'qty': qty};
  }
}

Future<BuildContext> adjustmentContext(WidgetTester tester) async {
  late BuildContext result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          result = context;
          return const Scaffold();
        },
      ),
    ),
  );
  return result;
}
