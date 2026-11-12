// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/user/widget/user_detail_card_widget.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
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

class _NoopSystemConfigurationController extends SystemConfigurationController {
  @override
  void onInit() {}
}

void main() {
  setUpAll(() {
    dotenv.testLoad(mergeWith: {'API_URL': 'http://localhost:8000'});
  });

  testWidgets('user detail uses supplier themed section cards', (tester) async {
    Get.reset();
    Get.testMode = true;
    Get.put(
      UserController(
        service: _Users(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
    Get.to(
      () => UserDetailCardWidget(),
      arguments: {
        'id': 1,
        'name': 'Alice',
        'email': 'alice@example.com',
        'is_active': true,
      },
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeSectionCard), findsWidgets);
  });

  testWidgets('user detail renders incomplete records safely', (tester) async {
    Get.reset();
    Get.testMode = true;
    Get.put(
      UserController(
        service: _Users(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
    Get.to(
      () => UserDetailCardWidget(),
      arguments: {'id': 1, 'name': null, 'is_active': false},
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });
}
