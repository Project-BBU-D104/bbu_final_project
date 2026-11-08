import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/manage_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/manage/manage_screen.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';

class FakeStorageService implements IStorageService {
  String role = 'cashier';

  @override
  Map<String, dynamic> get lastUserLoginRead => {
        'token': 'token',
        'user': {'id': 1, 'role': role},
      };

  @override
  String get currentUserRole => role;

  @override
  bool hasRole(String role) =>
      currentUserRole.trim().toLowerCase() == role.trim().toLowerCase();

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

Widget app() {
  return GetMaterialApp(
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => ManageScreen()),
      GetPage(
        name: AppRoutes.customer,
        page: () => const Scaffold(body: Text('customer page')),
      ),
      GetPage(
        name: AppRoutes.salePayment,
        page: () => const Scaffold(body: Text('sale payment page')),
      ),
      GetPage(
        name: AppRoutes.warehouseStock,
        page: () => const Scaffold(body: Text('warehouse stock page')),
      ),
      GetPage(
        name: AppRoutes.auditLogs,
        page: () => const Scaffold(body: Text('audit logs page')),
      ),
    ],
  );
}

List<String> visibleItemTitles(ManageController controller) {
  return [
    for (final section in controller.accessibleSections)
      for (final item in section['items'] as List) item['title'] as String,
  ];
}

Future<void> tapTile(WidgetTester tester, String title) async {
  final tile = find.text(title);
  expect(tile, findsWidgets);
  await tester.ensureVisible(tile.first);
  await tester.tap(tile.first);
  await tester.pumpAndSettle();
}

void main() {
  final fake = FakeStorageService();

  setUpAll(() {
    locator.registerSingleton<IStorageService>(fake);
  });

  tearDown(() {
    Get.reset();
  });

  test('cashier can access Customer and Sale Payment but not Warehouse Stock or Audit Logs', () {
    fake.role = 'cashier';
    final controller = ManageController();

    final titles = visibleItemTitles(controller);

    expect(titles, contains('Customer'));
    expect(titles, contains('Sale Payment'));
    expect(titles, isNot(contains('Warehouse Stock')));
    expect(titles, isNot(contains('Audit Logs')));
    expect(
      controller.accessibleSections.map((section) => section['title']),
      isNot(contains('History Management')),
    );
  });

  test('stock manager can access Warehouse Stock but not Customer, Sale Payment, or Audit Logs', () {
    fake.role = 'stock manager';
    final controller = ManageController();

    final titles = visibleItemTitles(controller);

    expect(titles, contains('Warehouse Stock'));
    expect(titles, isNot(contains('Customer')));
    expect(titles, isNot(contains('Sale Payment')));
    expect(titles, isNot(contains('Audit Logs')));
  });

  for (final role in ['admin', 'owner']) {
    test('$role can access all four restored tiles and History Management', () {
      fake.role = role;
      final controller = ManageController();

      final titles = visibleItemTitles(controller);

      expect(titles, contains('Customer'));
      expect(titles, contains('Sale Payment'));
      expect(titles, contains('Warehouse Stock'));
      expect(titles, contains('Audit Logs'));
      expect(
        controller.accessibleSections.map((section) => section['title']),
        contains('History Management'),
      );
    });
  }

  testWidgets('cashier taps Customer and Sale Payment tiles to navigate', (
    tester,
  ) async {
    fake.role = 'cashier';
    await tester.pumpWidget(app());

    await tapTile(tester, 'Customer');
    expect(Get.currentRoute, AppRoutes.customer);

    Get.back();
    await tester.pumpAndSettle();

    await tapTile(tester, 'Sale Payment');
    expect(Get.currentRoute, AppRoutes.salePayment);
  });

  testWidgets('cashier does not see denied tiles', (tester) async {
    fake.role = 'cashier';
    await tester.pumpWidget(app());

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Sale Payment'), findsOneWidget);
    expect(find.text('Warehouse Stock'), findsNothing);
    expect(find.text('Audit Logs'), findsNothing);
    expect(find.text('History Management'), findsNothing);
  });

  testWidgets('stock manager taps Warehouse Stock tile to navigate', (
    tester,
  ) async {
    fake.role = 'stock manager';
    await tester.pumpWidget(app());

    await tapTile(tester, 'Warehouse Stock');
    expect(Get.currentRoute, AppRoutes.warehouseStock);
  });

  testWidgets('admin taps Audit Logs tile to navigate', (tester) async {
    fake.role = 'admin';
    await tester.pumpWidget(app());

    await tapTile(tester, 'Audit Logs');
    expect(Get.currentRoute, AppRoutes.auditLogs);
  });
}
