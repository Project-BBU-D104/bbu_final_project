import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart' as search;
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'stock_adjustment_test_support.dart';

void main() {
  setUp(setUpAdjustmentTests);
  tearDown(Get.reset);
  late FakeStockAdjustmentService service;
  late FakeAdjustmentStockService stock;
  late StockAdjustmentController c;
  setUp(() {
    service = FakeStockAdjustmentService();
    stock = FakeAdjustmentStockService();
    c = StockAdjustmentController(
      service: service,
      warehouseStockService: stock,
      currentUserId: () => 5,
      onStockChanged: () async {},
    );
  });
  tearDown(() => c.onClose());
  Future<void> draft() async {
    c.selectedWarehouse.value = '1';
    c.selectedProduct.value = '1';
    c.selectedAdjustmentType.value = 'increase';
    c.adjustmentQtyController.text = '3';
    await c.loadCurrentQty();
    c.calculateNewQty();
  }

  test('latest stock selection wins', () async {
    stock.gates['1/1'] = Completer();
    stock.gates['1/2'] = Completer();
    c.selectedWarehouse.value = '1';
    c.selectedProduct.value = '1';
    final a = c.loadCurrentQty();
    c.selectedProduct.value = '2';
    final b = c.loadCurrentQty();
    stock.gates['1/2']!.complete({'qty': 20});
    await b;
    stock.gates['1/1']!.complete({'qty': 10});
    await a;
    expect(c.currentQty.value, 20);
    expect(c.currentQtyController.text, '20');
  });
  test('increase and decrease previews use valid integers', () async {
    await draft();
    expect(c.newQtyController.text, '13');
    c.selectedAdjustmentType.value = 'decrease';
    c.calculateNewQty();
    expect(c.newQtyController.text, '7');
    for (final value in ['', '1.5', '-1', '0', 'abc']) {
      c.adjustmentQtyController.text = value;
      expect(c.validateDraft(), false);
    }
  });
  test('edited increase reverses live stock before preview', () async {
    await draft();
    c.editingAdjustment.value = adjustmentJson(1);
    stock.qty = 15;
    c.adjustmentQtyController.text = '4';
    await c.loadCurrentQty();
    expect(c.currentQtyController.text, '12');
    expect(c.newQtyController.text, '16');
    c.calculateNewQty();
    expect(c.currentQtyController.text, '12');
  });
  test('edited decrease and changed pairs use correct baseline', () async {
    await draft();
    c.editingAdjustment.value = adjustmentJson(1, type: 'decrease');
    stock.qty = 7;
    c.selectedAdjustmentType.value = 'decrease';
    c.adjustmentQtyController.text = '4';
    await c.loadCurrentQty();
    expect(c.currentQtyController.text, '10');
    expect(c.newQtyController.text, '6');
    c.selectedProduct.value = '2';
    stock.qty = 20;
    await c.loadCurrentQty();
    expect(c.currentQtyController.text, '20');
    expect(c.newQtyController.text, '16');
  });
  testWidgets('stock failure is unknown and cannot save', (tester) async {
    final context = await adjustmentContext(tester);
    await draft();
    stock.fail = true;
    await c.loadCurrentQty();
    await c.onSaveStockAdjustment(context);
    expect(c.currentQtyKnown.value, false);
    expect(
      c.stockError.value,
      'Unable to load current stock. Please try again.',
    );
    expect(service.createCalls, 0);
  });
  testWidgets('invalid reversal or excessive decrease prevents update', (
    tester,
  ) async {
    final context = await adjustmentContext(tester);
    await draft();
    c.editingAdjustment.value = adjustmentJson(1);
    stock.qty = 2;
    await c.loadCurrentQty();
    expect(c.validateDraft(), false);
    await c.onUpdateStockAdjustment(context, 1);
    expect(service.updateCalls, 0);
    c.editingAdjustment.value = null;
    stock.qty = 10;
    c.selectedAdjustmentType.value = 'decrease';
    c.adjustmentQtyController.text = '11';
    await c.loadCurrentQty();
    expect(c.validateDraft(), false);
  });
  testWidgets('adjustment payload retains server authority', (tester) async {
    final context = await adjustmentContext(tester);
    await draft();
    await c.onSaveStockAdjustment(context);
    expect(service.payload, containsPair('qty', 3));
    expect(service.payload, containsPair('user_id', 5));
    expect(service.payload, containsPair('product_id', 1));
    expect(service.payload, containsPair('warehouse_id', 1));
    expect(service.payload!.containsKey('previous_qty'), false);
    expect(service.payload!.containsKey('new_qty'), false);
  });
  testWidgets('missing session blocks write and retains draft', (tester) async {
    c.onClose();
    c = StockAdjustmentController(
      service: service,
      warehouseStockService: stock,
      currentUserId: () => null,
    );
    final context = await adjustmentContext(tester);
    await draft();
    await c.onSaveStockAdjustment(context);
    expect(service.createCalls, 0);
    expect(c.formError.value, 'Sign in again to save this adjustment.');
    expect(c.adjustmentQtyController.text, '3');
  });
  testWidgets('save guard includes preflight and committed readback failure', (
    tester,
  ) async {
    final context = await adjustmentContext(tester);
    await draft();
    service.writeGate = Completer();
    final first = c.onSaveStockAdjustment(context);
    await tester.pump();
    await c.onSaveStockAdjustment(context);
    expect(service.createCalls, 1);
    service.failGet = true;
    service.writeGate!.complete();
    await first;
    expect(c.loadError.value, isNotEmpty);
    expect(c.formError.value, isEmpty);
    expect(c.adjustmentQtyController.text, isEmpty);
  });
  testWidgets('failed mutation retains draft and never refreshes dependents', (
    tester,
  ) async {
    c.onClose();
    var refreshed = 0;
    c = StockAdjustmentController(
      service: service,
      warehouseStockService: stock,
      currentUserId: () => 5,
      onStockChanged: () async {
        refreshed++;
      },
    );
    final context = await adjustmentContext(tester);
    await draft();
    service.failWrite = true;
    c.referenceController.text = 'ref';
    c.reasonController.text = 'reason';
    await c.onSaveStockAdjustment(context);
    expect(refreshed, 0);
    expect(c.adjustmentQtyController.text, '3');
    expect(c.referenceController.text, 'ref');
    expect(c.reasonController.text, 'reason');
    expect(
      c.formError.value,
      'Unable to save stock adjustment. Please try again.',
    );
  });
  test('refresh retains query and safe missing relations', () async {
    await c.getStockAdjustments();
    c.searchStockAdjustment('rice');
    service.items.add({
      ...adjustmentJson(2),
      'product': null,
      'warehouse': null,
    });
    await c.onRefresh();
    expect(c.searchStockAdjustmentList.length, 1);
    expect(c.stockAdjustmentList.length, 2);
  });
  test('clear invalidates pending stock response', () async {
    stock.gates['1/1'] = Completer();
    c.selectedWarehouse.value = '1';
    c.selectedProduct.value = '1';
    final pending = c.loadCurrentQty();
    c.clearForm();
    stock.gates['1/1']!.complete({'qty': 20});
    await pending;
    expect(c.currentQtyKnown.value, false);
    expect(c.currentQtyController.text, isEmpty);
  });
  testWidgets(
    'fresh preflight rejects changed availability and duplicate submit',
    (tester) async {
      final context = await adjustmentContext(tester);
      await draft();
      c.selectedAdjustmentType.value = 'decrease';
      c.adjustmentQtyController.text = '8';
      stock.gates['1/1'] = Completer();
      final saving = c.onSaveStockAdjustment(context);
      await tester.pump();
      await c.onSaveStockAdjustment(context);
      expect(service.createCalls, 0);
      expect(c.isSaving.value, true);
      stock.gates['1/1']!.complete({'qty': 7});
      await saving;
      expect(service.createCalls, 0);
      expect(c.formError.value, 'Quantity exceeds available stock.');
      expect(c.adjustmentQtyController.text, '8');
    },
  );
  testWidgets('late list cannot overwrite committed movement', (tester) async {
    final context = await adjustmentContext(tester);
    await draft();
    service.listGate = Completer();
    final gate = service.listGate!;
    final oldLoad = c.getStockAdjustments();
    service.listGate = null;
    await c.onSaveStockAdjustment(context);
    gate.complete([adjustmentJson(99)]);
    await oldLoad;
    expect(c.stockAdjustmentList.any((e) => e['id'] == 99), false);
    expect(c.stockAdjustmentList.any((e) => e['id'] == 2), true);
  });
  test('disposed search worker and lookup cannot mutate state', () async {
    c.onClose();
    final keyword = Get.put(search.SearchController());
    keyword.keyword.value = 'rice';
    c = Get.put(
      StockAdjustmentController(service: service, warehouseStockService: stock),
    );
    await c.getStockAdjustments();
    expect(c.searchStockAdjustmentList.length, 1);
    stock.gates['1/1'] = Completer();
    c.selectedWarehouse.value = '1';
    c.selectedProduct.value = '1';
    final pending = c.loadCurrentQty();
    Get.delete<StockAdjustmentController>();
    keyword.keyword.value = 'missing';
    stock.gates['1/1']!.complete({'qty': 50});
    await pending;
    expect(c.searchStockAdjustmentList.length, 1);
    expect(c.currentQtyKnown.value, false);
  });
  testWidgets('late edit response leaves destination and draft unchanged', (
    tester,
  ) async {
    final context = await adjustmentContext(tester);
    service.editGate = Completer();
    c.referenceController.text = 'retained';
    final opening = c.editStockAdjustment(context, 1);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Destination')),
      ),
    );
    await tester.pumpAndSettle();
    service.editGate!.complete(adjustmentJson(1));
    await opening;
    await tester.pumpAndSettle();
    expect(find.text('Destination'), findsOneWidget);
    expect(c.referenceController.text, 'retained');
    expect(c.editingAdjustment.value, isNull);
  });
  testWidgets(
    'committed movement refreshes all registered stock read models locally',
    (tester) async {
      bindAdjustmentOptions();
      final ws =
          Get.put<WarehouseStockController>(AdjustmentWarehouseStockDouble())
              as AdjustmentWarehouseStockDouble;
      c.onClose();
      c = StockAdjustmentController(
        service: service,
        warehouseStockService: stock,
        currentUserId: () => 5,
      );
      final context = await adjustmentContext(tester);
      await draft();
      await c.onSaveStockAdjustment(context);
      expect(
        (Get.find<WarehouseController>() as AdjustmentWarehouseDouble)
            .refreshCalls,
        1,
      );
      expect(
        (Get.find<ProductController>() as AdjustmentProductDouble).refreshCalls,
        1,
      );
      expect(ws.refreshCalls, 1);
    },
  );
  testWidgets('fresh preflight permits stock replenished since preview', (
    tester,
  ) async {
    final context = await adjustmentContext(tester);
    await draft();
    c.selectedAdjustmentType.value = 'decrease';
    c.adjustmentQtyController.text = '12';
    expect(c.validateDraft(), false);
    stock.qty = 15;
    await c.onSaveStockAdjustment(context);
    expect(service.createCalls, 1);
    expect(service.payload, containsPair('qty', 12));
  });
}
