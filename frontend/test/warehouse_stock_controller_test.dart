import 'dart:async';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/search_controller.dart' as search;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';
import 'warehouse_stock_test_support.dart';

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());
  test('stock draft rejects invalid and duplicate rows', () {
    final s = FakeWarehouseStockService();
    final c = WarehouseStockController(service: s);
    c.onClearWarehouseStock();
    c.selectedWarehouse.value = '1';
    (c.productRows.first['product'] as RxnString).value = '1';
    for (final qty in ['', '-1', '1.5']) {
      (c.productRows.first['qty'] as TextEditingController).text = qty;
      expect(c.validateDraft(), false);
    }
    (c.productRows.first['qty'] as TextEditingController).text = '0';
    expect(c.validateDraft(), true);
    c.addProductRow();
    (c.productRows.last['product'] as RxnString).value = '1';
    (c.productRows.last['qty'] as TextEditingController).text = '2';
    expect(c.validateDraft(), false);
    expect(s.createCalls, 0);
    c.onClose();
  });
  test('stock edit cannot submit more than one row', () {
    final c = WarehouseStockController();
    c.onClearWarehouseStock();
    c.addProductRow();
    c.editingStockId.value = 1;
    expect(c.validateDraft(), false);
    c.addProductRow();
    expect(c.productRows.length, 2);
    c.onClose();
  });
  test('stock query survives refresh with nullable relations', () async {
    final s = FakeWarehouseStockService()
      ..rows = [warehouseStockJson(1)..['product'] = null];
    final c = WarehouseStockController(service: s);
    c.searchWarehouseStock('1');
    await c.getWarehouseStock();
    expect(c.searchwarehouseStockList.single['id'], 1);
    expect(c.loadError.value, isEmpty);
    s.failRead = true;
    await c.getWarehouseStock();
    expect(c.warehouseStockList.length, 1);
    expect(c.loadError.value, isNotEmpty);
    c.onClose();
  });

  test('row reset and close dispose without double disposal', () {
    final c = WarehouseStockController(service: FakeWarehouseStockService());
    c.onClearWarehouseStock();
    c.addProductRow();
    final removed = c.productRows.last['qty'] as TextEditingController;
    c.removeProductRow(1);
    expect(() => removed.addListener(() {}), throwsFlutterError);
    final reset = c.productRows.single['qty'] as TextEditingController;
    c.onClearWarehouseStock();
    expect(() => reset.addListener(() {}), throwsFlutterError);
    expect(c.productRows.length, 1);
    c.onClose();
  });
  test('read-model refresh never creates missing controllers', () async {
    final c = WarehouseStockController(service: FakeWarehouseStockService());
    await c.refreshStockReadModels();
    expect(Get.isRegistered<ProductController>(), false);
    expect(Get.isRegistered<WarehouseController>(), false);
    c.onClose();
  });
  test('read-model refresh settles independent failures', () async {
    final product =
        Get.put<ProductController>(StockProductController()..fail = true)
            as StockProductController;
    final warehouse =
        Get.put<WarehouseController>(StockWarehouseController())
            as StockWarehouseController;
    final c = WarehouseStockController(service: FakeWarehouseStockService());
    await c.refreshStockReadModels();
    expect(product.getCalls, 1);
    expect(warehouse.getCalls, 1);
    c.onClose();
  });
  test('disposed search worker stops changing the query', () async {
    final c = Get.put(
      WarehouseStockController(service: FakeWarehouseStockService()),
    );
    await c.getWarehouseStock();
    final query = Get.find<search.SearchController>();
    query.keyword.value = 'before';
    await Get.delete<WarehouseStockController>();
    query.keyword.value = 'after';
    expect(c.searchQuery.value, 'before');
  });
  testWidgets(
    'stock zero quantity keeps API payload and refreshes once despite read failure',
    (tester) async {
      final s = FakeWarehouseStockService();
      var changed = 0;
      final c = WarehouseStockController(
        service: s,
        onStockChanged: () async {
          changed++;
          throw Exception('dependent read');
        },
      );
      c.onClearWarehouseStock();
      c.selectedWarehouse.value = '1';
      (c.productRows.single['product'] as RxnString).value = '1';
      (c.productRows.single['qty'] as TextEditingController).text = '0';
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      );
      s.failRead = true;
      await c.onSaveWarehouseStock(context);
      expect(s.lastCreatedData, {
        'warehouse_id': 1,
        'items': [
          {'product_id': 1, 'qty': 0},
        ],
      });
      expect(s.createCalls, 1);
      expect(changed, 1);
      expect(c.loadError.value, isNotEmpty);
      expect(c.formError.value, isEmpty);
      c.onClose();
    },
  );
  testWidgets('stock save is guarded and failure keeps rows', (tester) async {
    final s = FakeWarehouseStockService()
      ..writeGate = Completer()
      ..failWrite = true;
    final c = WarehouseStockController(service: s);
    c.onClearWarehouseStock();
    c.selectedWarehouse.value = '1';
    c.addProductRow();
    for (var i = 0; i < c.productRows.length; i++) {
      (c.productRows[i]['product'] as RxnString).value = '${i + 1}';
      (c.productRows[i]['qty'] as TextEditingController).text = '2';
    }
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );
    final saving = c.onSaveWarehouseStock(context);
    await c.onSaveWarehouseStock(context);
    c.removeProductRow(1);
    c.addProductRow();
    c.onClearWarehouseStock();
    expect(s.createCalls, 1);
    expect(c.productRows.length, 2);
    s.writeGate!.complete();
    await saving;
    expect(c.productRows.length, 2);
    expect(c.formError.value, isNotEmpty);
    c.onClose();
  });
  test('older stock list request cannot replace newer records', () async {
    final s = FakeWarehouseStockService()..readGate = Completer();
    final c = WarehouseStockController(service: s);
    final first = c.getWarehouseStock();
    final gate = s.readGate!;
    s.readGate = null;
    s.rows = [warehouseStockJson(2)];
    await c.getWarehouseStock();
    gate.complete([warehouseStockJson(1)]);
    await first;
    expect(c.warehouseStockList.single['id'], 2);
    c.onClose();
  });

  testWidgets('delete stock stays on list and suppresses stale list response', (
    tester,
  ) async {
    final s = FakeWarehouseStockService();
    final c = Get.put(WarehouseStockController(service: s));
    late BuildContext context;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/warehouse-stock',
        getPages: [
          GetPage(
            name: '/warehouse-stock',
            page: () => Scaffold(
              body: Builder(
                builder: (value) {
                  context = value;
                  return const Text('stock-list');
                },
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    s.readGate = Completer();
    final stale = c.getWarehouseStock();
    final gate = s.readGate!;
    s.readGate = null;
    await c.onDeleteWarehouseStock(1, context);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    gate.complete([warehouseStockJson(1)]);
    await stale;
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 1);
    expect(c.warehouseStockList, isEmpty);
    expect(Get.currentRoute, '/warehouse-stock');
  });
  testWidgets('late edit after navigation does not open a form', (
    tester,
  ) async {
    final s = FakeWarehouseStockService()..detailGate = Completer();
    final c = Get.put(WarehouseStockController(service: s));
    late BuildContext context;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (value) {
              context = value;
              return const Text('list');
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final opening = c.editWarehouseStock(context, 1);
    Get.to(() => const Scaffold(body: Text('destination')));
    await tester.pumpAndSettle();
    s.detailGate!.complete(warehouseStockJson(1));
    await opening;
    await tester.pumpAndSettle();
    expect(find.text('destination'), findsOneWidget);
    expect(c.editingStockId.value, isNull);
  });
}
