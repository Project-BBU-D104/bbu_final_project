import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/warehouse/widget/ware_house_detail_widget.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> warehouseJson(int id, String name) => {
  'id': id,
  'name': name,
  'reference_no': '',
  'location': 'Phnom Penh',
  'note': '',
  'warehouse_stock': null,
  'created_at': null,
  'updated_at': null,
};

class FakeWarehouseService extends WarehouseService {
  List<Map<String, dynamic>> items = [
    warehouseJson(1, 'Alpha'),
    warehouseJson(2, 'Beta'),
  ];
  bool failGet = false, failWrite = false, nonList = false;
  int getCalls = 0, createCalls = 0, updateCalls = 0, deleteCalls = 0;
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  Completer<dynamic>? getGate, createGate, editGate;
  @override
  Future<dynamic> getWarehouses() async {
    getCalls++;
    if (getGate != null) return getGate!.future;
    if (failGet) throw Exception('private server error');
    return nonList ? {} : List<Map<String, dynamic>>.from(items);
  }

  @override
  Future<dynamic> getWarehouseById(int id) async => editGate != null
      ? editGate!.future
      : items.firstWhere((r) => r['id'] == id);
  @override
  Future<dynamic> createWarehouse(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (createGate != null) await createGate!.future;
    if (failWrite) throw Exception('private server error');
    final item = {...warehouseJson(3, ''), ...data};
    items = [...items, item];
    return item;
  }

  @override
  Future<dynamic> updateWarehouse(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failWrite) throw Exception('private server error');
    final item = {...warehouseJson(id, ''), ...data};
    items = [
      for (final r in items)
        if (r['id'] == id) item else r,
    ];
    return item;
  }

  @override
  Future<dynamic> deleteWarehouse(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('private server error');
    items = items.where((r) => r['id'] != id).toList();
    return true;
  }
}

void setUpWarehouseTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpWarehouseHost(
  WidgetTester tester, {
  required Widget home,
  String route = AppRoutes.warehouse,
  Size size = const Size(390, 844),
  bool dark = false,
  Locale locale = const Locale('en', 'US'),
  double textScale = 1,
  double keyboardInset = 0,
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
      initialRoute: route,
      getPages: [
        GetPage(name: route, page: () => home),
        if (route != AppRoutes.warehouseDetail)
          GetPage(
            name: AppRoutes.warehouseDetail,
            page: () => WareHouseDetailWidget(),
          ),
        GetPage(
          name: '/other',
          page: () => const Scaffold(body: Text('Other page')),
        ),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
          disableAnimations: true,
        ),
        child: DesktopAppShell(route: Get.currentRoute, child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}
