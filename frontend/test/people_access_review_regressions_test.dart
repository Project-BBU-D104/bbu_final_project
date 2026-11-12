// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/screen/user/widget/user_card_list_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:get/get.dart';

class _Users implements UserService {
  int calls = 0;
  @override
  Future<dynamic> getUsers() async {
    calls++;
    return [
      {'id': 1, 'name': 'Alice', 'created_at': 'not-a-date', 'is_active': true},
      {'id': 2, 'name': 'Bob', 'created_at': '2026-01-01', 'is_active': true},
    ];
  }

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
  Future<dynamic> getRoles() async => [
    {'id': 'bad', 'name': null, 'description': null, 'created_at': 'bad'},
  ];
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

  testWidgets('user card tolerates malformed dates and missing names', (
    tester,
  ) async {
    Get.reset();
    Get.put(
      UserController(
        service: _Users(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: UserCardListWidget(user: {'id': 1, 'created_at': 'invalid'}),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });

  testWidgets('role card tolerates malformed fields and invalid ids', (
    tester,
  ) async {
    Get.reset();
    Get.put(RoleController(service: _Roles()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: RoleCardWidget(
            role: {'id': 'invalid', 'created_at': 'invalid'},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });

  test('user search remains applied after a refresh', () async {
    Get.reset();
    final service = _Users();
    final controller = UserController(
      service: service,
      systemConfigurationCtr: _NoopSystemConfigurationController(),
    );

    await controller.getUserList();
    controller.searchUser('alice');
    await controller.getUserList();

    expect(controller.searchUserList, hasLength(1));
    expect(controller.searchUserList.single['name'], 'Alice');
  });
}
