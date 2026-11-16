import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/edit_warehouse_widget.dart';
import 'package:get/get.dart';
import 'warehouse_test_support.dart';

void main() {
  setUp(setUpWarehouseTests);
  tearDown(() => Get.reset());
  test('refresh preserves warehouse query', () async {
    final s = FakeWarehouseService();
    final c = WarehouseController(service: s);
    await c.getWarehouses();
    c.searchWarehouse('alpha');
    await c.onRefresh();
    expect(c.searchQuery.value, 'alpha');
    expect(c.searchWarehouseList.single['id'], 1);
    c.onClose();
  });
  test('failed and non-list loads retain records', () async {
    final s = FakeWarehouseService();
    final c = WarehouseController(service: s);
    await c.getWarehouses();
    s.failGet = true;
    await c.getWarehouses();
    expect(c.warehouseList.length, 2);
    expect(c.loadError.value, isNotEmpty);
    s.failGet = false;
    s.nonList = true;
    await c.getWarehouses();
    expect(c.warehouseList.length, 2);
    expect(c.loadError.value, isNotEmpty);
    expect(c.isLoading.value, false);
    c.onClose();
  });
  testWidgets('concurrent saves send one request', (tester) async {
    final s = FakeWarehouseService()..createGate = Completer<dynamic>();
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              c.onSaveWarehouse(context);
              c.onSaveWarehouse(context);
            },
            child: const Text('Write'),
          ),
        ),
      ),
    );
    c.warehouseNameController.text = 'Alpha';
    c.warehouseLocationController.text = 'Phnom Penh';
    await tester.tap(find.text('Write'));
    await tester.pump();
    expect(s.createCalls, 1);
    expect(c.isSaving.value, true);
    s.createGate!.complete(null);
    await tester.pumpAndSettle();
  });
  testWidgets('save failure retains warehouse draft', (tester) async {
    final s = FakeWarehouseService()..failWrite = true;
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => c.onSaveWarehouse(context),
            child: const Text('Write'),
          ),
        ),
      ),
    );
    c.warehouseNameController.text = 'Alpha';
    c.warehouseLocationController.text = 'Phnom Penh';
    await tester.tap(find.text('Write'));
    await tester.pumpAndSettle();
    expect(c.warehouseNameController.text, 'Alpha');
    expect(c.formError.value, 'Unable to save warehouse. Please try again.');
  });
  testWidgets('committed save survives refresh failure', (tester) async {
    final s = FakeWarehouseService();
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => c.addWarehouse(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(AddWarehouseWidget));
    c.warehouseNameController.text = 'Gamma';
    c.warehouseLocationController.text = 'Phnom Penh';
    s.failGet = true;
    await c.onSaveWarehouse(context);
    await tester.pumpAndSettle();
    expect(s.createCalls, 1);
    expect(find.byType(AddWarehouseWidget), findsNothing);
    expect(c.loadError.value, isNotEmpty);
  });
  testWidgets('late load cannot resurrect deleted warehouse', (tester) async {
    final s = FakeWarehouseService();
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => c.deleteWarehouse(context, 1),
            child: const Text('Remove'),
          ),
        ),
      ),
    );
    final old = Completer<dynamic>();
    s.getGate = old;
    final loading = c.getWarehouses();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    s.getGate = null;
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    old.complete([warehouseJson(1, 'Alpha')]);
    await loading;
    await tester.pumpAndSettle();
    expect(c.warehouseList.any((r) => r['id'] == 1), false);
  });
  testWidgets('late edit does not open on another route', (tester) async {
    final s = FakeWarehouseService()..editGate = Completer<dynamic>();
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => c.editWarehouse(context, 1),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    Get.toNamed('/other');
    await tester.pumpAndSettle();
    s.editGate!.complete(warehouseJson(1, 'Alpha'));
    await tester.pumpAndSettle();
    expect(find.byType(EditWarehouseWidget), findsNothing);
    expect(Get.currentRoute, '/other');
  });
  test('disposed warehouse controller stops observing search', () async {
    final search = Get.put(SearchController())..keyword.value = 'alpha';
    final c = Get.put(WarehouseController(service: FakeWarehouseService()));
    await Future<void>.delayed(Duration.zero);
    expect(c.searchQuery.value, 'alpha');
    c.onClose();
    search.keyword.value = 'beta';
    expect(c.searchQuery.value, 'alpha');
  });
}
