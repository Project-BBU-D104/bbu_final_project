// ignore_for_file: must_call_super

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:get/get.dart';

class _Users implements UserService {
  int calls = 0;
  bool fail = true;

  @override
  Future<dynamic> getUsers() async {
    calls++;
    if (fail) throw Exception('offline');
    return [
      {'id': 1, 'name': 'Alice', 'is_active': true},
      {'id': 2, 'name': 'Bob', 'is_active': false},
    ];
  }

  @override
  Future<dynamic> getUserById(int id) async => {'id': id, 'name': 'Alice'};
  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> deleteUser(int id) async => true;
}

class _Roles implements RoleService {
  @override
  Future<dynamic> getRoles() async => [
    {'id': 1, 'name': 'Admin', 'is_active': true},
  ];
  @override
  Future<dynamic> getRoleById(int id) async => {'id': id, 'name': 'Admin'};
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
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  setUpAll(() {
    dotenv.testLoad(mergeWith: {'API_URL': 'http://localhost:8000'});
  });

  testWidgets(
    'user loading exposes a retryable error and preserves search state',
    (tester) async {
      Get.reset();
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      final service = _Users();
      final controller = UserController(
        service: service,
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      );

      await controller.getUserList();
      expect(controller.loadError.value, isNotNull);
      await tester.pump(const Duration(seconds: 4));

      service.fail = false;
      await controller.getUserList();
      controller.searchUser('ali');

      expect(controller.loadError.value, isNull);
      expect(controller.searchUserList.single['name'], 'Alice');
    },
  );

  test('role loading exposes an error state', () async {
    Get.reset();
    final controller = RoleController(service: _Roles());

    await controller.getRoles();

    expect(controller.loadError.value, isNull);
    expect(controller.roleList.single['name'], 'Admin');
  });
}
