// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/role/widget/role_form_widget.dart';
import 'package:frontend/services/main_service/role_service.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';

class _Roles implements RoleService {
  int createCalls = 0;

  @override
  Future<dynamic> getRoles() async => [];
  @override
  Future<dynamic> getRoleById(int id) async => {
    'name': 'Stock Clerk',
    'description': 'Counts stock',
    'is_active': true,
  };
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
  testWidgets(
    'role name stays single-line while description accepts newlines',
    (tester) async {
      final controller = Get.put(RoleController(service: _Roles()));
      addTearDown(Get.reset);
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: RoleFormWidget())),
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Stock\nClerk');
      await tester.enterText(fields.at(1), 'Counts\nstock');
      expect(controller.roleNameController.text, 'StockClerk');
      expect(controller.roleDescriptionController.text, 'Counts\nstock');
    },
  );

  testWidgets('narrow role form keeps save above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);
    Get.testMode = true;
    addTearDown(Get.reset);
    final controller = Get.put(RoleController(service: _Roles()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => controller.addRole(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(save).dy, lessThanOrEqualTo(240));
    expect(save.hitTestable(), findsOneWidget);
  });

  testWidgets('role actions are reachable in a short desktop dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.testMode = true;
    addTearDown(Get.reset);
    final controller = Get.put(RoleController(service: _Roles()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => controller.addRole(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    final open = find.text('Open');
    final context = tester.element(open);
    await tester.tap(open);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AppFormSection), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Save'));
    expect(find.text('Save').hitTestable(), findsOneWidget);
    final cancel = find.text('Cancel');
    await tester.ensureVisible(cancel);
    expect(cancel.hitTestable(), findsOneWidget);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    final edit = controller.editRole(context, 7);
    await tester.pumpAndSettle();
    expect(find.text('Edit Role'), findsOneWidget);
    expect(find.text('Stock Clerk'), findsOneWidget);
    expect(find.text('Counts stock'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    await tester.ensureVisible(find.text('Update'));
    expect(find.text('Update').hitTestable(), findsOneWidget);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    await edit;
  });

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
