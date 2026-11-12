import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/services/main_service/purchase/purchase_request_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> purchaseRequestJson(
  int id, {
  String requestNo = 'REQ-1',
  String requestType = 'purchase',
  int? warehouseId = 1,
  String requestedBy = 'Old Name',
  String approvedBy = 'Pending',
  String status = 'pending',
  String reason = 'Restock',
  String? requestDate = '2026-01-02T00:00:00',
  String? approvedDate = '2026-01-02T00:00:00',
}) => {
  'id': id,
  'request_no': requestNo,
  'request_type': requestType,
  'warehouse_id': warehouseId,
  'requested_by': requestedBy,
  'approved_by': approvedBy,
  'status': status,
  'reason': reason,
  'request_date': requestDate,
  'approved_date': approvedDate,
};

Map<String, dynamic> purchaseRequestItemJson(
  int id, {
  int requestId = 1,
  int productId = 1,
  String unit = 'pcs',
  int qty = 2,
}) => {
  'id': id,
  'stock_request_id': requestId,
  'product_id': productId,
  'unit': unit,
  'qty': qty,
};

class FakePurchaseRequestService implements PurchaseRequestService {
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> items = [];
  bool failGet = false;
  bool failWrite = false;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;
  Map<String, dynamic>? lastCreatedItemData;
  Completer<dynamic>? createGate;

  @override
  Future<dynamic> getPurchaseRequests() async {
    if (failGet) throw Exception('offline');
    return requests;
  }

  @override
  Future<dynamic> getPurchaseRequestById(int id) async {
    if (failGet) throw Exception('offline');
    return requests.firstWhere((request) => request['id'] == id);
  }

  @override
  Future<dynamic> createPurchaseRequest(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (failWrite) throw Exception('failed');
    await createGate?.future;
    final created = {'id': 3, ...data};
    requests = [...requests, created];
    return created;
  }

  @override
  Future<dynamic> updatePurchaseRequest(
    int id,
    Map<String, dynamic> data,
  ) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failWrite) throw Exception('failed');
    final updated = {...data, 'id': id};
    requests = [
      for (final request in requests)
        if (request['id'] == id) updated else request,
    ];
    return updated;
  }

  @override
  Future<dynamic> deletePurchaseRequest(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    requests = requests.where((request) => request['id'] != id).toList();
    return true;
  }

  @override
  Future<dynamic> getPurchaseRequestItems() async {
    if (failGet) throw Exception('offline');
    return items;
  }

  @override
  Future<dynamic> createPurchaseRequestItem(Map<String, dynamic> data) async {
    lastCreatedItemData = data;
    if (failWrite) throw Exception('failed');
    final created = {'id': 10, ...data};
    items = [...items, created];
    return created;
  }

  @override
  Future<dynamic> updatePurchaseRequestItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    if (failWrite) throw Exception('failed');
    return {'id': id, ...data};
  }

  @override
  Future<dynamic> deletePurchaseRequestItem(int id) async {
    if (failWrite) throw Exception('failed');
    items = items.where((item) => item['id'] != id).toList();
    return true;
  }
}

class FakeWarehouseController extends WarehouseController {
  FakeWarehouseController() {
    warehouseList.assignAll([
      {'id': 1, 'name': 'Main'},
      {'id': 2, 'name': 'Backup'},
    ]);
  }

  @override
  Future<void> getWarehouses() async {}
}

class FakeProductController extends ProductController {
  final List<Map<String, dynamic>> seeded = [
    {'id': 1, 'name': 'Widget'},
    {'id': 2, 'name': 'Gadget'},
  ];

  @override
  List<Map<String, dynamic>> get products => seeded;

  @override
  Future<void> getProducts({bool showLoading = true}) async {}
}

void setUpPurchaseRequestTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpPurchaseRequestHost(
  WidgetTester tester, {
  required Widget home,
  Size size = const Size(390, 844),
  bool dark = false,
  Locale locale = const Locale('en', 'US'),
  double textScale = 1,
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: DesktopAppShell(route: '/purchase-request', child: child!),
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}
