import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/user/widget/edit_user_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class _FakeUserService implements UserService {
  final user = <String, dynamic>{
    'id': 1,
    'name': 'admin',
    'email': 'admin@example.com',
    'phone': '012345678',
    'photo': '',
    'is_active': true,
    'role': {'id': 1, 'name': 'Admin'},
    'system_configuration_id': null,
  };

  @override
  Future<dynamic> getUsers() async => [user];

  @override
  Future<dynamic> getUserById(int id) async => user;

  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> deleteUser(int id) async => true;
}

class _NoopSystemConfigurationController
    extends SystemConfigurationController {
  @override
  void onInit() {}
}

class _FakeRoleService implements RoleService {
  @override
  Future<dynamic> getRoles() async => [
    {'id': 1, 'name': 'Admin'},
  ];

  @override
  Future<dynamic> getRoleById(int id) async => {'id': 1, 'name': 'Admin'};

  @override
  Future<dynamic> createRole(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateRole(int id, Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> deleteRole(int id) async => true;
}

void main() {
  setUpAll(() {
    dotenv.testLoad(mergeWith: {'API_URL': 'http://localhost:8000'});
  });

  testWidgets('opening the edit user sheet twice does not throw', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.reset();

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  Get.find<UserController>().editUser(context, 1),
              child: const Text('edit'),
            ),
          ),
        ),
      ),
    );

    Get.put(
      UserController(
        service: _FakeUserService(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    Get.put(RoleController(service: _FakeRoleService()));
    await tester.pump();

    final context = tester.element(find.text('edit'));
    final ctr = Get.find<UserController>();
    ctr.editUser(context, 1);
    ctr.editUser(context, 1);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
