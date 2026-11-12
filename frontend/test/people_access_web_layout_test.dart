import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/role/role_screen.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/screen/role/widget/role_form_widget.dart';
import 'package:frontend/screen/user/widget/user_form_widget.dart';
import 'package:frontend/screen/user/user_screen.dart';
import 'package:frontend/screen/user/widget/user_card_list_widget.dart';
import 'package:frontend/screen/user/widget/user_detail_card_widget.dart';
import 'package:frontend/screen/user/widget/user_table_list_widget.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

import 'people_access_web_test_support.dart';

void main() {
  setUp(setUpPeopleWebTests);
  tearDown(Get.reset);

  Future<void> openUsers(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    double textScale = 1,
    bool dark = false,
    List<Map<String, dynamic>> extra = const [],
  }) async {
    final service = FakeWebUserService()..items.addAll(extra);
    final controller = Get.put(
      UserController(
        service: service,
        systemConfigurationCtr: NoopSystemConfigurationController(),
      ),
    );
    await pumpPeopleHost(
      tester,
      home: UserScreen(),
      size: size,
      textScale: textScale,
      dark: dark,
    );
    controller.userList.assignAll(service.items);
    controller.searchUser('');
    await tester.pumpAndSettle();
  }

  Future<void> openRoles(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    double textScale = 1,
    bool dark = false,
    List<Map<String, dynamic>> extra = const [],
  }) async {
    final service = FakeWebRoleService()..items.addAll(extra);
    final controller = Get.put(RoleController(service: service));
    await pumpPeopleHost(
      tester,
      home: RoleScreen(),
      route: '/role',
      size: size,
      textScale: textScale,
      dark: dark,
    );
    controller.roleList.assignAll(service.items);
    controller.searchRole('');
    await tester.pumpAndSettle();
  }

  Future<void> pumpUserForm(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(
      UserController(
        service: FakeWebUserService(),
        systemConfigurationCtr: NoopSystemConfigurationController(),
      ),
    );
    Get.put(RoleController(service: FakeWebRoleService()));
    await tester.pumpWidget(
      GetMaterialApp(home: Scaffold(body: UserFormWidget())),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpRoleForm(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(RoleController(service: FakeWebRoleService()));
    await tester.pumpWidget(
      GetMaterialApp(home: Scaffold(body: RoleFormWidget())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('user table matches the supplier web table', (tester) async {
    await openUsers(tester);
    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.showCheckboxColumn, isFalse);
    expect(table.dataRowColor!.resolve({WidgetState.hovered}), isNotNull);
    expect(table.headingTextStyle?.fontWeight, FontWeight.w600);
    expect(
      tester.getSize(find.byType(DataTable)).width,
      greaterThanOrEqualTo(960),
    );
    expect(find.byTooltip('View details'), findsNWidgets(2));
    expect(find.byTooltip('user1@example.com'), findsOneWidget);
    final status = tester.widget<StatusWidget>(find.byType(StatusWidget).first);
    expect(status.color, AppTheme.light().colorScheme.primaryContainer);
  });

  testWidgets('user table row opens the detail route', (tester) async {
    await openUsers(tester);
    await tester.tap(find.byTooltip('View details').first);
    await tester.pumpAndSettle();
    expect(find.byType(UserDetailCardWidget), findsOneWidget);
  });

  testWidgets('desktop user list actions are 48px with no AppBar', (
    tester,
  ) async {
    await openUsers(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Add User')).height,
      48,
    );
    expect(tester.getSize(find.byTooltip('Refresh')).height, 48);
  });

  testWidgets('user list falls back to cards at large text scale', (
    tester,
  ) async {
    await openUsers(tester, textScale: 1.4);
    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(UserCardListWidget), findsWidgets);
  });

  testWidgets('user table renders malformed records safely', (tester) async {
    await openUsers(
      tester,
      extra: [
        {
          'id': 3,
          'name': null,
          'photo': null,
          'role': 'not-a-map',
          'is_active': null,
          'created_at': 'garbage',
        },
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });

  testWidgets('user actions ignore non-numeric ids', (tester) async {
    await openUsers(
      tester,
      extra: [
        {'id': 'abc', 'name': 'Bad'},
      ],
    );
    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('user table status is themed in dark mode', (tester) async {
    await openUsers(tester, dark: true);
    final status = tester.widget<StatusWidget>(find.byType(StatusWidget).first);
    expect(status.color, AppTheme.dark().colorScheme.primary);
  });

  testWidgets('role table matches the supplier web table', (tester) async {
    await openRoles(tester);
    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.showCheckboxColumn, isFalse);
    expect(table.dataRowColor!.resolve({WidgetState.hovered}), isNotNull);
    expect(
      tester.getSize(find.byType(DataTable)).width,
      greaterThanOrEqualTo(960),
    );
    final status = tester.widget<StatusWidget>(find.byType(StatusWidget).first);
    expect(status.color, AppTheme.light().colorScheme.primaryContainer);
  });

  testWidgets('role table formats created dates', (tester) async {
    await openRoles(tester);
    expect(find.text('02-01-2026'), findsNWidgets(2));
    expect(find.text('2026-01-02T00:00:00'), findsNothing);
  });

  testWidgets('role actions ignore non-numeric ids', (tester) async {
    await openRoles(
      tester,
      extra: [
        {'id': 'abc', 'name': 'Bad'},
      ],
    );
    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('role list falls back to cards at large text scale', (
    tester,
  ) async {
    await openRoles(tester, textScale: 1.4);
    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(RoleCardWidget), findsWidgets);
  });

  testWidgets('role table renders malformed records safely', (tester) async {
    await openRoles(
      tester,
      extra: [
        {
          'id': 3,
          'name': null,
          'description': null,
          'is_active': null,
          'created_at': 'garbage',
        },
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });

  testWidgets('role table status is themed in dark mode', (tester) async {
    await openRoles(tester, dark: true);
    final status = tester.widget<StatusWidget>(find.byType(StatusWidget).first);
    expect(status.color, AppTheme.dark().colorScheme.primary);
  });

  testWidgets('desktop user detail keeps edit and delete in its page header', (
    tester,
  ) async {
    await openUsers(tester);
    Get.find<UserController>().gotoUserDetail(userJson(1, 'Alice'));
    await tester.pumpAndSettle();
    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(UserDetailCardWidget),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.appBar, isNull);
    expect(scaffold.bottomNavigationBar, isNull);
    expect(find.byType(HomeTabLayout), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(tester.getRect(find.text('Edit')).top, lessThan(220));
    expect(tester.getRect(find.text('Delete')).top, lessThan(220));
  });

  testWidgets('desktop user detail shows sections side by side at 900+', (
    tester,
  ) async {
    await openUsers(tester);
    Get.find<UserController>().gotoUserDetail(userJson(1, 'Alice'));
    await tester.pumpAndSettle();
    final cards = find.byType(HomeSectionCard);
    expect(
      tester.getRect(cards.first).right,
      lessThan(tester.getRect(cards.last).left),
    );
  });

  testWidgets('mobile user detail keeps the bottom action bar', (tester) async {
    await openUsers(tester, size: const Size(390, 844));
    Get.find<UserController>().gotoUserDetail(userJson(1, 'Alice'));
    await tester.pumpAndSettle();
    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(UserDetailCardWidget),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('user form pairs email and phone on wide content', (
    tester,
  ) async {
    await pumpUserForm(tester, const Size(1400, 900));
    final email = tester.getRect(find.text('Email'));
    final phone = tester.getRect(find.text('Phone Number'));
    expect(email.top, closeTo(phone.top, 1));
    expect(email.right, lessThan(phone.left));
    final role = tester.getRect(find.text('Role'));
    final config = tester.getRect(find.text('System Configuration'));
    expect(role.top, closeTo(config.top, 1));
  });

  testWidgets('user form stacks fields on narrow content', (tester) async {
    await pumpUserForm(tester, const Size(390, 844));
    expect(
      tester.getRect(find.text('Phone Number')).top,
      greaterThan(tester.getRect(find.text('Email')).bottom),
    );
  });

  testWidgets('role form pairs name and description on wide content', (
    tester,
  ) async {
    await pumpRoleForm(tester, const Size(1400, 900));
    final name = tester.getRect(find.text('Role Name'));
    final desc = tester.getRect(find.text('Description'));
    expect(name.top, closeTo(desc.top, 1));
    expect(name.right, lessThan(desc.left));
  });
}
