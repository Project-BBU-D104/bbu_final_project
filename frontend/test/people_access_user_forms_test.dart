// ignore_for_file: must_call_super

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/services/main_service/user_service.dart';
import 'package:frontend/screen/user/widget/user_form_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';

class _SlowUsers implements UserService {
  final createResponse = Completer<dynamic>();
  int createCalls = 0;
  @override
  Future<dynamic> getUsers() async => [];
  @override
  Future<dynamic> getUserById(int id) async => {
    'name': 'Stock Clerk',
    'role': {'id': 1},
    'system_configuration_id': 2,
  };
  @override
  Future<dynamic> createUser(Map<String, dynamic> data) async {
    createCalls++;
    return createResponse.future;
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

class _NoopRoleController extends RoleController {
  @override
  void onInit() {}
}

Future<void> _openableForm(
  WidgetTester tester,
  Size size, {
  _SlowUsers? service,
  bool editing = false,
  bool khmer = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Get.reset();
  Get.testMode = true;
  addTearDown(Get.reset);
  Get.put<RoleController>(
    _NoopRoleController()
      ..roleList.assignAll([
        {'id': 1, 'name': 'Warehouse Role'},
      ]),
  );
  final configs = _NoopSystemConfigurationController();
  configs.systemConfigurationList.assignAll([
    {'id': 2, 'company_name': 'Stock Company'},
  ]);
  final controller = Get.put(
    UserController(
      service: service ?? _SlowUsers(),
      systemConfigurationCtr: configs,
    ),
  );
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslation(),
      locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => editing
                ? controller.editUser(context, 7)
                : controller.addUser(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
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
      GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: UserFormWidget()),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(service.createCalls, 0);
    expect(find.text('Please enter username'), findsOneWidget);
  });

  testWidgets('user form opens as a dialog on wide screens', (tester) async {
    await _openableForm(tester, const Size(1024, 480));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AppFormSection), findsNWidgets(2));
    final save = find.text('Save');
    await tester.ensureVisible(save);
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user account text fields reject embedded newlines', (
    tester,
  ) async {
    await _openableForm(tester, const Size(1024, 480));
    final fields = find.byType(TextFormField);
    for (final (index, input, expected) in [
      (0, 'Stock\nClerk', 'StockClerk'),
      (1, 'stock\n@example.com', 'stock@example.com'),
      (2, '012\n345678', '012345678'),
    ]) {
      final field = fields.at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, input);
      expect(tester.widget<TextFormField>(field).controller?.text, expected);
    }
  });

  testWidgets('narrow Khmer user sheet keeps actions above the keyboard', (
    tester,
  ) async {
    await _openableForm(tester, const Size(390, 640), khmer: true);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('អ៊ីមែល')).dy,
      lessThan(tester.getTopLeft(find.text('លេខទូរស័ព្ទ')).dy),
    );
    expect(
      tester.getTopLeft(find.text('តួនាទី')).dy,
      lessThan(tester.getTopLeft(find.text('ការកំណត់ប្រព័ន្ធ')).dy),
    );
    final cancel = find.widgetWithText(OutlinedButton, 'បោះបង់');
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    expect(cancel.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(cancel).dy, lessThanOrEqualTo(400));
    final save = find.byType(FilledButton);
    await tester.ensureVisible(save);
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(save).dy, lessThanOrEqualTo(400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('user edit keeps prefilled account and access values', (
    tester,
  ) async {
    await _openableForm(tester, const Size(1024, 480), editing: true);
    expect(find.text('Edit User'), findsOneWidget);
    expect(find.text('Stock Clerk'), findsOneWidget);
    final dropdowns = find.byType(DropdownButtonFormField<String>);
    expect(tester.state<FormFieldState<String>>(dropdowns.at(0)).value, '1');
    expect(tester.state<FormFieldState<String>>(dropdowns.at(1)).value, '2');
    await tester.ensureVisible(find.text('Update'));
    expect(find.text('Update').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user form blocks dismissal during a pending save', (
    tester,
  ) async {
    final service = _SlowUsers();
    await _openableForm(tester, const Size(1024, 480), service: service);
    await tester.enterText(find.byType(TextFormField).first, 'Stock Clerk');
    final dropdowns = find.byType(DropdownButtonFormField<String>);
    for (final (index, value) in [
      (0, 'Warehouse Role'),
      (1, 'Stock Company'),
    ]) {
      await tester.ensureVisible(dropdowns.at(index));
      await tester.tap(dropdowns.at(index));
      await tester.pumpAndSettle();
      await tester.tap(find.text(value).last);
      await tester.pumpAndSettle();
    }
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();

    expect(service.createCalls, 1);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    final close = find.widgetWithIcon(IconButton, Icons.close);
    expect(tester.widget<IconButton>(close).onPressed, isNull);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(Dialog), findsOneWidget);
    service.createResponse.complete({});
    await tester.pumpAndSettle();
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
      GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: UserFormWidget()),
      ),
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
