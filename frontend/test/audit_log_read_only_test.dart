import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/audit_logs/audit_logs_screen.dart';
import 'package:frontend/screen/audit_logs/widget/audit_log_detail_widget.dart';
import 'package:frontend/services/storage_service.dart';
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

Widget app() {
  return GetMaterialApp(
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
}
