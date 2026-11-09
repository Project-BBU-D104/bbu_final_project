import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/supplier/widgets/supplier_detail_card_widget.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> supplierJson(int id, String name, {bool status = true}) => {
  'id': id, 'name': name, 'phone': '012345678',
  'email': 'supplier@example.com', 'map': null, 'address': null,
  'status': status, 'created_at': null, 'updated_at': null,
};

class FakeSupplierService implements SupplierService {
  List<Map<String, dynamic>> items = [supplierJson(1, 'Alpha'), supplierJson(2, 'Beta')];
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  int getCalls = 0, getByIdCalls = 0, createCalls = 0, updateCalls = 0, deleteCalls = 0;
  bool failGet = false, failWrite = false;
  @override
  Future<dynamic> getSuppliers() async {
    getCalls++;
    if (failGet) throw Exception('offline');
    return items;
  }
  @override
  Future<dynamic> getSupplierById(int id) async {
    getByIdCalls++;
    return items.firstWhere((s) => s['id'] == id);
  }
  @override
  Future<dynamic> createSupplier(Map<String, dynamic> data) async {
    createCalls++; lastCreatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...supplierJson(3, ''), ...data};
    items = [...items, item];
    return item;
  }
  @override
  Future<dynamic> updateSupplier(int id, Map<String, dynamic> data) async {
    updateCalls++; lastUpdatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...supplierJson(id, ''), ...data};
    items = [for (final s in items) if (s['id'] == id) item else s];
    return item;
  }
  @override
  Future<dynamic> deleteSupplier(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    items = items.where((s) => s['id'] != id).toList();
    return true;
  }
}

void setUpSupplierTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpSupplierHost(WidgetTester tester, {
  required Widget home, Size size = const Size(390, 844), bool dark = false,
  Locale locale = const Locale('en', 'US'), double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(GetMaterialApp(
    translations: AppTranslation(), locale: locale,
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    defaultTransition: Transition.noTransition,
    getPages: [GetPage(name: AppRoutes.supplierDetail, page: () => SupplierDetailCardWidget())],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale), disableAnimations: true),
      child: DesktopAppShell(route: '/supplier', child: child!),
    ), home: home,
  ));
  await tester.pumpAndSettle();
}
