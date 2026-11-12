// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/role/role_screen.dart';
import 'package:frontend/screen/user/user_screen.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:get/get.dart';

class _Users implements UserService {
  @override
  Future<dynamic> getUsers() async => [];
  @override
  Future<dynamic> getUserById(int id) async => {};
  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> deleteUser(int id) async => true;
}

class _Roles implements RoleService {
  @override
  Future<dynamic> getRoles() async => [];
  @override
  Future<dynamic> getRoleById(int id) async => {};
  @override
  Future<dynamic> createRole(Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> updateRole(int id, Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> deleteRole(int id) async => true;
}

class _NoopSystemConfigurationController extends SystemConfigurationController {
  @override
  void onInit() {}
}

void main() {
  setUpAll(() {
    dotenv.testLoad(mergeWith: {'API_URL': 'http://localhost:8000'});
  });

  testWidgets('People and Access routes retain their list surfaces', (
    tester,
  ) async {
    Get.reset();
    Get.testMode = true;
    Get.put(
      UserController(
        service: _Users(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    Get.put(RoleController(service: _Roles()));

    await tester.pumpWidget(
      GetMaterialApp(home: const SizedBox(), getPages: AppPages.pages),
    );
    expect(AppPages.pages.any((page) => page.name == AppRoutes.user), isTrue);
    expect(AppPages.pages.any((page) => page.name == AppRoutes.role), isTrue);
    expect(
      AppPages.pages.any((page) => page.name == AppRoutes.userDetail),
      isTrue,
    );

    await tester.pumpWidget(GetMaterialApp(home: UserScreen()));
    await tester.pump();
    expect(find.text('Add User'), findsOneWidget);

    await tester.pumpWidget(GetMaterialApp(home: RoleScreen()));
    await tester.pump();
    expect(find.text('Add Role'), findsOneWidget);
  });
}
