import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/purchases/widget/purchase_detail_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_service.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> purchaseItemJson(
  int id, {
  int purchaseId = 1,
  int? productId = 1,
  String? productName = 'Widget',
  double qty = 2,
  double cost = 5,
}) => {
  'id': id,
  'purchase_id': purchaseId,
  'product': productId == null ? null : {'id': productId, 'name': productName},
  'qty': qty,
  'cost_price': cost,
  'subtotal': qty * cost,
};

Map<String, dynamic> purchaseJson(
  int id, {
  String? invoiceNo = 'INV-1',
  int? supplierId = 1,
  String? supplierName = 'Alpha',
  String? purchaseDate = '2026-01-02T00:00:00',
  String status = 'ordered',
  String paymentStatus = 'unpaid',
  double total = 10,
  double paid = 0,
  double due = 10,
  List<Map<String, dynamic>>? items,
}) => {
  'id': id,
  'invoice_no': invoiceNo,
  'supplier': supplierId == null
      ? null
      : {'id': supplierId, 'name': supplierName},
  'warehouse': {'id': 1, 'name': 'Main'},
  'user': {'id': 5, 'name': 'Admin'},
  'purchase_date': purchaseDate,
  'description': null,
  'status': status,
  'payment_status': paymentStatus,
  'subtotal': total,
  'tax_amount': 0,
  'discount_amount': 0,
  'total_amount': total,
  'paid_amount': paid,
  'due_amount': due,
  'purchase_items': items ?? [purchaseItemJson(id * 10)],
};

class FakePurchaseService implements PurchaseService {
  List<Map<String, dynamic>> items = [
    purchaseJson(1),
    purchaseJson(2, invoiceNo: 'BETA-2', supplierId: 2, supplierName: 'Beta'),
  ];
  bool failGet = false, failWrite = false;
  int getCalls = 0,
      getByIdCalls = 0,
      createCalls = 0,
      updateCalls = 0,
      deleteCalls = 0;
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  Completer<dynamic>? createGate;

  @override
  Future<dynamic> getPurchases() async {
    getCalls++;
    if (failGet) throw Exception('offline');
    return items;
  }

  @override
  Future<dynamic> getRecentPurchases() async => getPurchases();

  @override
  Future<dynamic> getPurchaseById(int id) async {
    getByIdCalls++;
    return items.firstWhere((p) => p['id'] == id);
  }

  @override
  Future<dynamic> createPurchase(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {'id': 3, ...purchaseJson(3), ...data};
    items = [...items, item];
    return item;
  }

  @override
  Future<dynamic> updatePurchase(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {
      ...purchaseJson(id),
      ...items.firstWhere((p) => p['id'] == id),
      ...data,
    };
    items = [
      for (final p in items)
        if (p['id'] == id) item else p,
    ];
    return item;
  }

  @override
  Future<dynamic> deletePurchase(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    items = items.where((p) => p['id'] != id).toList();
    return true;
  }
}

class DelayedPurchaseService extends FakePurchaseService {
  @override
  Future<dynamic> createPurchase(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    final result = await createGate!.future;
    items = [
      ...items,
      {'id': 3, ...purchaseJson(3), ...data},
    ];
    return result;
  }
}

class FakeProductController extends ProductController {
  @override
  List<Map<String, dynamic>> get products => [
    {'id': 1, 'name': 'Widget'},
    {'id': 2, 'name': 'Gadget'},
  ];

  @override
  Future<void> getProducts({bool showLoading = true}) async {}
}

class FakeWarehouseController extends WarehouseController {
  FakeWarehouseController() {
    warehouseList.assignAll([
      {'id': 1, 'name': 'Main'},
    ]);
  }

  @override
  Future<void> getWarehouses() async {}
}

class FakePurchaseSupplierService extends SupplierService {
  @override
  Future<dynamic> getSuppliers() async => [
    {
      'id': 1,
      'name': 'Alpha',
      'phone': '012345678',
      'email': 'alpha@example.com',
      'map': null,
      'address': null,
      'status': true,
      'created_at': null,
      'updated_at': null,
    },
    {
      'id': 2,
      'name': 'Beta',
      'phone': '098765432',
      'email': 'beta@example.com',
      'map': null,
      'address': null,
      'status': true,
      'created_at': null,
      'updated_at': null,
    },
  ];
}

void setUpPurchaseTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
  Get.put<ProductController>(FakeProductController());
  Get.put<WarehouseController>(FakeWarehouseController());
  Get.put<SupplierController>(
    SupplierController(service: FakePurchaseSupplierService()),
  );
}

Future<void> pumpPurchaseHost(
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
      getPages: [
        GetPage(
          name: AppRoutes.purchaseDetail,
          page: () => PurchaseDetailWidget(),
        ),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: DesktopAppShell(route: '/purchase', child: child!),
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}
