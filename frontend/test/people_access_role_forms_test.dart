// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/role/widget/role_form_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:get/get.dart';

class _Roles implements RoleService {
  int createCalls = 0;

  @override
  Future<dynamic> getRoles() async => [];
  @override
  Future<dynamic> getRoleById(int id) async => {};
  @override
  Future<dynamic> createRole(Map<String, dynamic> data) async {
    createCalls++;
    return data;
  }

  @override
  Future<dynamic> updateRole(int id, Map<String, dynamic> data) async => data;
  @override
  Future<dynamic> deleteRole(int id) async => true;
}

void main() {
  testWidgets('role form validates a blank name before writing', (
    tester,
  ) async {
    Get.reset();
    Get.testMode = true;
    final service = _Roles();
    Get.put(RoleController(service: service));
    await tester.pumpWidget(
      GetMaterialApp(home: Scaffold(body: RoleFormWidget())),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(service.createCalls, 0);
    expect(find.text('Please enter role name'), findsOneWidget);
  });
}
