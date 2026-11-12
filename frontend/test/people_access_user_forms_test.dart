// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/screen/user/widget/user_form_widget.dart';
import 'package:get/get.dart';

class _SlowUsers implements UserService {
  int createCalls = 0;
  @override
  Future<dynamic> getUsers() async => [];
  @override
  Future<dynamic> getUserById(int id) async => {};
  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async {
    createCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    throw Exception('failed');
  }

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

  testWidgets('user form rejects blank username before writing', (
    tester,
  ) async {
    Get.reset();
    Get.testMode = true;
    final service = _SlowUsers();
    Get.put(
      UserController(
        service: service,
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(home: Scaffold(body: UserFormWidget())),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(service.createCalls, 0);
    expect(find.text('Please enter username'), findsOneWidget);
  });

  testWidgets('user form opens as a dialog on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.reset();
    Get.testMode = true;
    Get.put(
      UserController(
        service: _SlowUsers(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Get.find<UserController>().addUser(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('user form uses supplier rounded filled fields', (tester) async {
    Get.reset();
    Get.testMode = true;
    Get.put(
      UserController(
        service: _SlowUsers(),
        systemConfigurationCtr: _NoopSystemConfigurationController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(home: Scaffold(body: UserFormWidget())),
    );
    await tester.pump();

    final field = tester.widget<InputDecorator>(
      find.byType(InputDecorator).first,
    );
    expect(field.decoration.filled, isTrue);
    expect(field.decoration.border, isA<OutlineInputBorder>());
    expect(
      (field.decoration.border! as OutlineInputBorder).borderRadius,
      BorderRadius.circular(12),
    );
  });
}
