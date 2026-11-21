import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/audit_logs/audit_event.dart';
import 'package:frontend/screen/audit_logs/audit_logs_screen.dart';
import 'package:frontend/screen/audit_logs/widget/audit_log_detail_widget.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/services/main_service/audit_log_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:get/get.dart';

class FakeStorageService implements IStorageService {
  @override
  Map<String, dynamic> get lastUserLoginRead => {};

  @override
  String get currentUserRole => '';

  @override
  bool hasRole(String role) => false;

  @override
  T? readStorage<T>(StorageKey key) => null;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {}

  @override
  Future<void> removeStorage(StorageKey key) async {}

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {}

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  String get appStartUpRead => '';

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}
}

class FakeAuditLogController extends AuditLogController {
  FakeAuditLogController(this.fixedLog);

  final Map<String, dynamic> fixedLog;

  @override
  Future<void> getAuditLogs() async {
    auditLogs.value = [fixedLog];
  }
}

class FakeAuditLogService extends AuditLogService {
  Object response = <Map<String, dynamic>>[];

  @override
  Future<dynamic> getAuditLogs() async {
    if (response is Exception) throw response;
    return response;
  }
}

final fixedLog = <String, dynamic>{
  'id': 1,
  'title': 'Updated Product price',
  'action': 'UPDATE',
  'table_name': 'product',
  'record_id': 5,
  'user': {'name': 'Alice'},
  'created_at': '2026-11-08 10:00:00',
  'old_value': jsonEncode({'name': 'Old Name'}),
  'new_value': jsonEncode({'name': 'New Name'}),
};

Widget app({
  Locale locale = const Locale('en', 'US'),
  bool dark = false,
  bool desktopShell = false,
  double textScale = 1,
}) {
  return GetMaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    translations: AppTranslation(),
    locale: locale,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: desktopShell
          ? DesktopAppShell(route: AppRoutes.auditLogs, child: child!)
          : child!,
    ),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => AuditLogsScreen()),
      GetPage(
        name: AppRoutes.auditLogDetail,
        page: () => AuditLogDetailWidget(),
      ),
    ],
  );
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    locator.registerSingleton<IStorageService>(FakeStorageService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('audit log list has no add or mutation controls', (tester) async {
    Get.put<AuditLogController>(FakeAuditLogController(fixedLog));

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Updated Product price'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('audit log detail keeps values visible without edit or delete', (
    tester,
  ) async {
    Get.put<AuditLogController>(FakeAuditLogController(fixedLog));

    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Updated Product price'));
    await tester.pumpAndSettle();

    expect(find.text('Old Name'), findsOneWidget);
    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('search and action filter compose on a small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = FakeAuditLogService()
      ..response = [
        fixedLog,
        {...fixedLog, 'id': 2, 'title': 'Product archived', 'action': 'DELETE'},
        {
          ...fixedLog,
          'id': 3,
          'title': 'Supplier updated',
          'user': {'name': 'Bob'},
        },
      ];
    Get.put(AuditLogController(auditLogService: service));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  alice  ');
    await tester.pumpAndSettle();
    expect(find.text('Updated Product price'), findsOneWidget);
    expect(find.text('Product archived'), findsOneWidget);
    expect(find.text('Supplier updated'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deleted').last);
    await tester.pumpAndSettle();
    expect(find.text('Product archived'), findsOneWidget);
    expect(find.text('Updated Product price'), findsNothing);

    await tester.enterText(find.byType(TextField), 'unmatched');
    await tester.pumpAndSettle();
    expect(find.text('No matching audit events'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide history retains the query and events after refresh fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = FakeAuditLogService()..response = [fixedLog];
    Get.put(AuditLogController(auditLogService: service));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byType(AppTable<AuditEvent>), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Product');
    service.response = Exception('Internal failure');
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load audit history.'), findsOneWidget);
    expect(find.text('Updated Product price'), findsOneWidget);
    expect(find.text('Internal failure'), findsNothing);

    service.response = [
      {...fixedLog, 'title': 'Product created'},
      {...fixedLog, 'title': 'Order updated', 'table_name': 'order'},
    ];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Product created'), findsOneWidget);
    expect(find.text('Order updated'), findsNothing);
    expect(find.text('Unable to load audit history.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail retains both added and removed fields', (tester) async {
    Get.put<AuditLogController>(
      FakeAuditLogController({
        ...fixedLog,
        'old_value': {'removed_field': null, 'same': 'unchanged'},
        'new_value': '{"added_field":"new","same":"unchanged"}',
      }),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Updated Product price'));
    await tester.pumpAndSettle();
    expect(find.text('removed_field'), findsOneWidget);
    expect(find.text('added_field'), findsOneWidget);
    expect(find.text('null'), findsOneWidget);
    expect(find.text('Not recorded'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop history pages newest first and returns from detail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = FakeAuditLogService()
      ..response = [
        for (var day = 1; day <= 26; day++)
          {
            ...fixedLog,
            'id': day,
            'title': 'Event $day',
            'created_at': DateTime.utc(2026, 11, day).toIso8601String(),
          },
      ];
    Get.put(AuditLogController(auditLogService: service));
    await tester.pumpWidget(app(desktopShell: true));
    await tester.pumpAndSettle();

    expect(find.text('Event 26').hitTestable(), findsOneWidget);
    expect(find.text('Event 1'), findsNothing);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('26–26 of 26 audit events'), findsOneWidget);
    await tester.tap(find.text('Event 1'));
    await tester.pumpAndSettle();
    expect(find.text('Old Name'), findsOneWidget);
    expect(find.text('New Name'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Event 1'), findsOneWidget);
    expect(find.byType(AppTable<AuditEvent>), findsOneWidget);
  });

  testWidgets('Khmer dark history and detail wrap with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Get.put<AuditLogController>(
      FakeAuditLogController({
        ...fixedLog,
        'old_value': 'Historical value without JSON',
        'new_value': '',
      }),
    );
    await tester.pumpWidget(
      app(locale: const Locale('km', 'KH'), dark: true, textScale: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('សកម្មភាពទាំងអស់'), findsOneWidget);
    expect(find.byType(AppTable<AuditEvent>), findsNothing);
    await tester.tap(find.text('Updated Product price'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Historical value without JSON'),
      200,
    );
    expect(
      find.text('Historical value without JSON').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
