import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'dart:async';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';

Map<String, dynamic> warehouseStockJson(
  int id, {
  int warehouseId = 1,
  int productId = 1,
  int qty = 10,
}) => {
  'id': id,
  'warehouse_id': warehouseId,
  'product_id': productId,
  'qty': qty,
  'warehouse': {'id': warehouseId, 'name': 'Warehouse $warehouseId'},
  'product': {'id': productId, 'name': 'Product $productId'},
};

class FakeWarehouseStockService extends WarehouseStockService {
  List<Map<String, dynamic>> rows = [warehouseStockJson(1)];
  bool failRead = false, failWrite = false;
  int createCalls = 0, updateCalls = 0, deleteCalls = 0;
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  Completer<dynamic>? writeGate, readGate, detailGate;
  @override
  Future<dynamic> getWarehouseStock() async {
    if (readGate != null) return readGate!.future;
    if (failRead) throw Exception('read');
    return rows;
  }

  @override
  Future<dynamic> getWarehouseStockById(int id) async => detailGate == null
      ? rows.firstWhere((r) => r['id'] == id)
      : detailGate!.future;
  @override
  Future<dynamic> createWarehouseStock(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw Exception('write');
    return {};
  }

  @override
  Future<dynamic> updateWarehouseStock(
    int id,
    Map<String, dynamic> data,
  ) async {
    updateCalls++;
    lastUpdatedData = data;
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw Exception('write');
    return {};
  }

  @override
  Future<dynamic> deleteWarehouseStock(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('write');
    rows = rows.where((r) => r['id'] != id).toList();
    return {};
  }
}

// These doubles keep Warehouse stock tests independent of the warehouse stage.

class StockWarehouseService extends WarehouseService {
  bool fail = false;
  int calls = 0;
  @override
  Future<dynamic> getWarehouses() async {
    calls++;
    if (fail) throw Exception('lookup');
    return [
      {'id': 1, 'name': 'Warehouse 1'},
    ];
  }
}

class StockProductService extends ProductService {
  bool fail = false;
  int calls = 0;
  @override
  Future<dynamic> getProducts() async {
    calls++;
    if (fail) throw Exception('lookup');
    return [
      {'id': 1, 'name': 'Product 1'},
      {'id': 2, 'name': 'Product 2'},
    ];
  }
}

class StockWarehouseController extends WarehouseController {
  final _stockService = StockWarehouseService();
  @override
  StockWarehouseService get service => _stockService;
  int getCalls = 0;
  bool fail = false;
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getWarehouses() async {
    getCalls++;
    if (fail) throw Exception('refresh');
    warehouseList.assignAll(
      List<Map<String, dynamic>>.from(await service.getWarehouses()),
    );
  }
}

class StockProductController extends ProductController {
  StockProductController() : super(service: StockProductService());
  int getCalls = 0;
  bool fail = false;
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getProducts({bool showLoading = true}) async {
    getCalls++;
    if (fail) throw Exception('refresh');
  }
}

Future<void> pumpWarehouseStockHost(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  bool dark = false,
  bool khmer = false,
  double scale = 1,
  double keyboardInset = 0,
  bool shell = false,
}) async {
  tester.view.physicalSize = Size(width, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslation(),
      locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      builder: (context, navigator) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: shell
            ? DesktopAppShell(
                route: AppRoutes.warehouseStock,
                child: navigator!,
              )
            : navigator!,
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}
