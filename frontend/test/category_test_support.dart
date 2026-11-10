import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/services/main_service/category_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> categoryJson(
  int id,
  String name, {
  String description = 'Everyday goods',
  String? createdAt = '2026-01-02T00:00:00',
}) => {
  'id': id,
  'name': name,
  'description': description,
  'icon': null,
  'created_at': createdAt,
  'updated_at': null,
};

class FakeCategoryService implements CategoryService {
  List<Map<String, dynamic>> items = [
    categoryJson(1, 'Alpha'),
    categoryJson(2, 'Beta'),
  ];
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  int getCalls = 0,
      getByIdCalls = 0,
      createCalls = 0,
      updateCalls = 0,
      deleteCalls = 0;
  bool failGet = false, failWrite = false;

  @override
  Future<dynamic> getCategories() async {
    getCalls++;
    if (failGet) throw Exception('offline');
    return items;
  }

  @override
  Future<dynamic> getCategoryById(int id) async {
    getByIdCalls++;
    return items.firstWhere((c) => c['id'] == id);
  }

  @override
  Future<dynamic> createCategory(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...categoryJson(3, ''), ...data};
    items = [...items, item];
    return item;
  }

  @override
  Future<dynamic> updateCategory(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...categoryJson(id, ''), ...data};
    items = [
      for (final c in items)
        if (c['id'] == id) item else c,
    ];
    return item;
  }

  @override
  Future<dynamic> deleteCategory(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    items = items.where((c) => c['id'] != id).toList();
    return true;
  }
}

class DelayedCategoryService extends FakeCategoryService {
  Completer<dynamic>? refresh;
  final create = Completer<dynamic>();
  final edit = Completer<dynamic>();

  @override
  Future<dynamic> getCategories() {
    getCalls++;
    return refresh?.future ?? Future.value(items);
  }

  @override
  Future<dynamic> createCategory(Map<String, dynamic> data) {
    createCalls++;
    lastCreatedData = data;
    return create.future.then((value) {
      items = [...items, Map<String, dynamic>.from(value as Map)];
      return value;
    });
  }

  @override
  Future<dynamic> getCategoryById(int id) {
    getByIdCalls++;
    return edit.future;
  }
}

void setUpCategoryTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpCategoryHost(
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
        child: DesktopAppShell(route: '/category', child: child!),
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}
