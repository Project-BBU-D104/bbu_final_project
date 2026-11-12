// ignore_for_file: must_call_super

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/user/widget/user_detail_card_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';

import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> userJson(int id, String name, {bool active = true}) => {
  'id': id,
  'name': name,
  'email': 'user$id@example.com',
  'phone': '012345678',
  'photo': '',
  'role': {'id': 1, 'name': 'Admin'},
  'is_active': active,
  'created_at': '2026-01-02T00:00:00',
  'system_configuration_id': 1,
};

Map<String, dynamic> roleJson(int id, String name, {bool active = true}) => {
  'id': id,
  'name': name,
  'description': 'Role $name description',
  'is_active': active,
  'created_at': '2026-01-02T00:00:00',
};

class FakeWebUserService implements UserService {
  List<Map<String, dynamic>> items = [userJson(1, 'Alice'), userJson(2, 'Bob')];
  Map<String, dynamic>? lastCreatedData, lastUpdatedData;
  int getCalls = 0,
      getByIdCalls = 0,
      createCalls = 0,
      updateCalls = 0,
      deleteCalls = 0;
  bool failGet = false, failWrite = false;

  @override
  Future<dynamic> getUsers() async {
    getCalls++;
    if (failGet) throw Exception('offline');
    return items;
  }

  @override
  Future<dynamic> getUserById(int id) async {
    getByIdCalls++;
    return items.firstWhere((item) => item['id'] == id);
  }

  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...userJson(3, ''), ...data};
    items = [...items, item];
    return item;
  }

  @override
  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failWrite) throw Exception('failed');
    final item = {...userJson(id, ''), ...data};
    items = [
      for (final user in items)
        if (user['id'] == id) item else user,
    ];
    return item;
  }

  @override
  Future<dynamic> deleteUser(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    items = items.where((user) => user['id'] != id).toList();
    return true;
  }
}

class FakeWebRoleService implements RoleService {
  List<Map<String, dynamic>> items = [
    roleJson(1, 'Admin'),
    roleJson(2, 'Cashier'),
  ];

  @override
  Future<dynamic> getRoles() async => items;

  @override
  Future<dynamic> getRoleById(int id) async =>
      items.firstWhere((item) => item['id'] == id);

  @override
  Future<dynamic> createRole(Map<String, dynamic> data) async {
    final item = {...roleJson(3, ''), ...data};
    items = [...items, item];
    return item;
  }

  @override
  Future<dynamic> updateRole(int id, Map<String, dynamic> data) async {
    final item = {...roleJson(id, ''), ...data};
    items = [
      for (final role in items)
        if (role['id'] == id) item else role,
    ];
    return item;
  }

  @override
  Future<dynamic> deleteRole(int id) async {
    items = items.where((role) => role['id'] != id).toList();
    return true;
  }
}

class NoopSystemConfigurationController extends SystemConfigurationController {
  @override
  void onInit() {}
}

void setUpPeopleWebTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpPeopleHost(
  WidgetTester tester, {
  required Widget home,
  String route = '/user',
  Size size = const Size(1440, 900),
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
        GetPage(name: AppRoutes.userDetail, page: () => UserDetailCardWidget()),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: DesktopAppShell(route: route, child: child!),
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}
