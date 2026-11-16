import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:get/get.dart';
import 'stock_transfer_test_support.dart';

void main() {
  late FakeProductTransferService service;
  late FakeTransferStockService stocks;
  late ProductTransferController c;
  int refreshCount = 0;
  setUp(() {
    initTransferEnvironment();
    refreshCount = 0;
    Get.testMode = true;
    service = FakeProductTransferService();
    stocks = FakeTransferStockService();
    c = ProductTransferController(
      service: service,
      warehouseStockService: stocks,
      onStockChanged: () async {
        refreshCount++;
      },
    );
    c.warehouseStock.assignAll(stocks.records);
    c.selectedFromWarehouse.value = 1;
    c.selectedToWarehouse.value = 2;
  });
  tearDown(() {
    c.onClose();
    Get.reset();
  });
  void add(int qty) {
    c.selectedProduct.value = 1;
    c.quantityController.text = '$qty';
    c.addDraftItem();
  }

  test('same warehouse and empty transfer cannot save', () {
    c.selectedToWarehouse.value = 1;
    expect(c.validateDraft(), false);
    expect(service.createCalls, 0);
  });
  test('duplicate transfer products merge within availability', () {
    add(2);
    add(3);
    expect(c.transferItems.length, 1);
    expect(c.transferItems.single['qty'], 5);
    expect(c.totalDraftQuantity, 5);
  });
  test('invalid quantity never enters draft', () {
    for (final value in ['', '0', '-1', '1.5']) {
      c.selectedProduct.value = 1;
      c.quantityController.text = value;
      c.addDraftItem();
      expect(c.transferItems, isEmpty);
      expect(c.draftError.value, isNotEmpty);
    }
  });
  test('edited transfer counts original quantity back once', () async {
    c.editingTransfer.value = transferJson(1, qty: 5);
    stocks.records = [stockJson(qty: 2), stockJson(warehouse: 2, qty: 4)];
    await c.onGetWarehouseStock();
    expect(c.availableQtyFor(1), 7);
    await c.onGetWarehouseStock();
    expect(c.availableQtyFor(1), 7);
    c.selectFromWarehouse(2);
    expect(c.availableQtyFor(1), 4);
  });
  test('source change preserves items and detects invalid quantity', () {
    c.warehouseStock.add(stockJson(warehouse: 3, qty: 4));
    add(5);
    c.selectFromWarehouse(3);
    expect(c.transferItems.single['qty'], 5);
    expect(c.validateDraft(), false);
  });
  test('missing source product cannot be fabricated by edit addback', () {
    c.editingTransfer.value = transferJson(1, qty: 5);
    c.warehouseStock.clear();
    c.transferItems.assignAll([
      {'product_id': 1, 'qty': 5},
    ]);
    expect(c.validateDraft(), false);
  });
  test(
    'query retained across refresh and refresh failure retains records',
    () async {
      c.searchStockTransfer('missing');
      await c.onGetProductTransferList();
      expect(c.searchStockTransferList, isEmpty);
      expect(c.stockTransfer, hasLength(1));
      service.failList = true;
      await c.onRefresh();
      expect(c.stockTransfer, hasLength(1));
      expect(c.loadError.value, isNotEmpty);
    },
  );
  test('latest list response wins', () async {
    final old = Completer<dynamic>();
    service.listGate = old;
    final pending = c.onGetProductTransferList();
    service.listGate = null;
    service.records = [transferJson(2)];
    await c.onGetProductTransferList();
    old.complete([transferJson(1)]);
    await pending;
    expect(c.stockTransfer.single['id'], 2);
  });
  Future<BuildContext> host(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold();
          },
        ),
      ),
    );
    return ctx;
  }

  testWidgets('stock lookup failure blocks write without zero fallback', (
    tester,
  ) async {
    final ctx = await host(tester);
    add(5);
    stocks.fail = true;
    await c.onSaveStockTransfer(ctx);
    expect(c.stockError.value, isNotEmpty);
    expect(service.createCalls, 0);
    expect(c.totalDraftQuantity, 5);
  });
  testWidgets('preflight depletion retains draft without write', (
    tester,
  ) async {
    final ctx = await host(tester);
    add(5);
    stocks.records = [stockJson(qty: 3)];
    await c.onSaveStockTransfer(ctx);
    expect(service.createCalls, 0);
    expect(c.totalDraftQuantity, 5);
  });
  testWidgets('double submit during preflight sends one write', (tester) async {
    final ctx = await host(tester);
    add(3);
    stocks.gate = Completer<dynamic>();
    final first = c.onSaveStockTransfer(ctx);
    final second = c.onSaveStockTransfer(ctx);
    expect(c.isSaving.value, true);
    stocks.gate!.complete(stocks.records);
    await Future.wait([first, second]);
    expect(service.createCalls, 1);
    expect(refreshCount, 1);
  });
  testWidgets('transfer payload preserves date and items', (tester) async {
    final ctx = await host(tester);
    add(3);
    c.selectedDate.value = DateTime.utc(2026, 11, 14, 17, 30);
    await c.onSaveStockTransfer(ctx);
    expect(service.payload!['transfer_date'], '2026-11-14T17:30:00.000Z');
    expect(service.payload!['product_transfer_items'], [
      {'product_id': 1, 'qty': 3},
    ]);
    expect(service.payload!['from_warehouse_id'], 1);
    expect(service.payload!['to_warehouse_id'], 2);
  });
  testWidgets('server rejection retains whole transfer draft', (tester) async {
    final ctx = await host(tester);
    add(3);
    service.failWrite = true;
    c.productTransferRefController.text = 'KEEP';
    final date = c.selectedDate.value;
    await c.onSaveStockTransfer(ctx);
    expect(c.totalDraftQuantity, 3);
    expect(c.selectedFromWarehouse.value, 1);
    expect(c.productTransferRefController.text, 'KEEP');
    expect(c.selectedDate.value, date);
    expect(
      c.formError.value,
      'Unable to save stock transfer. Please try again.',
    );
  });
  testWidgets('committed write and failed refresh are separated', (
    tester,
  ) async {
    final ctx = await host(tester);
    add(3);
    service.failList = true;
    await c.onSaveStockTransfer(ctx);
    expect(service.createCalls, 1);
    expect(c.transferItems, isEmpty);
    expect(c.formError.value, isEmpty);
    expect(c.loadError.value, isNotEmpty);
  });
  test(
    'latest stock response wins and failed refresh invalidates warm stock',
    () async {
      final old = Completer<dynamic>();
      stocks.gate = old;
      final pending = c.onGetWarehouseStock();
      stocks.gate = null;
      stocks.records = [stockJson(qty: 4)];
      await c.onGetWarehouseStock();
      old.complete([stockJson(qty: 100)]);
      await pending;
      expect(c.availableQtyFor(1), 4);
      add(3);
      stocks.fail = true;
      await c.onGetWarehouseStock();
      expect(c.validateDraft(), false);
      expect(c.totalDraftQuantity, 3);
    },
  );
  test('disposed controller ignores late requests', () async {
    final localService = FakeProductTransferService();
    final gate = Completer<dynamic>();
    localService.listGate = gate;
    final local = ProductTransferController(
      service: localService,
      warehouseStockService: stocks,
    );
    final pending = local.onGetProductTransferList();
    local.onClose();
    gate.complete([transferJson(1)]);
    await pending;
    expect(local.stockTransfer, isEmpty);
  });
  testWidgets('late edit cannot navigate after host is removed', (
    tester,
  ) async {
    final ctx = await host(tester);
    service.detailGate = Completer<dynamic>();
    final pending = c.editStockTransfer(ctx, transferJson(1));
    await tester.pumpWidget(const SizedBox());
    service.detailGate!.complete(transferJson(1));
    await pending;
    expect(c.editingTransfer.value, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'update preflight counts original once and retains rejected edit',
    (tester) async {
      final ctx = await host(tester);
      final original = transferJson(1, qty: 5);
      c.editingTransfer.value = original;
      stocks.records = [stockJson(qty: 2)];
      c.transferItems.assignAll([
        {
          'product_id': 1,
          'product': {'id': 1, 'name': 'Rice'},
          'qty': 7,
        },
      ]);
      service.failWrite = true;
      await c.onUpdate(ctx, original);
      expect(service.updateCalls, 1);
      expect(c.totalDraftQuantity, 7);
      expect(c.availableQtyFor(1), 7);
      expect(c.editingTransfer.value, original);
    },
  );
  testWidgets(
    'default refresh updates registered dependent read models locally',
    (tester) async {
      final ctx = await host(tester);
      final warehouse =
          Get.put<WarehouseController>(TransferWarehouseController())
              as TransferWarehouseController;
      final product =
          Get.put<ProductController>(TransferProductController())
              as TransferProductController;
      final warehouseStock =
          Get.put<WarehouseStockController>(TransferWarehouseStockController())
              as TransferWarehouseStockController;
      final local = ProductTransferController(
        service: service,
        warehouseStockService: stocks,
      );
      local.selectedFromWarehouse.value = 1;
      local.selectedToWarehouse.value = 2;
      local.transferItems.assignAll([
        {'product_id': 1, 'qty': 3},
      ]);
      await local.onSaveStockTransfer(ctx);
      expect(warehouse.refreshCalls, 1);
      expect(product.refreshCalls, 1);
      expect(warehouseStock.refreshCalls, 1);
      local.onClose();
    },
  );
  testWidgets('committed transfer retains stock refresh failure feedback', (
    tester,
  ) async {
    final ctx = await host(tester);
    add(3);
    service.afterWrite = () => stocks.fail = true;
    await c.onSaveStockTransfer(ctx);
    expect(service.createCalls, 1);
    expect(c.transferItems, isEmpty);
    expect(c.formError.value, isEmpty);
    expect(
      c.loadError.value,
      'Transfer saved, but related stock could not be refreshed.',
    );
  });
}
