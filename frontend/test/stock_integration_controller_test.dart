import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_form_widget.dart';
import 'package:frontend/widget/confirm_dailog_widget.dart';
import 'package:get/get.dart';

import 'stock_transfer_test_support.dart';
import 'warehouse_stock_test_support.dart' as stock;

void main() {
  setUp(() {
    initTransferEnvironment();
    Get.testMode = true;
  });
  tearDown(Get.reset);

  Future<BuildContext> host(WidgetTester tester) async {
    late BuildContext origin;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/origin',
        getPages: [
          GetPage(
            name: '/origin',
            page: () => Scaffold(
              body: Builder(
                builder: (context) {
                  origin = context;
                  return const Text('origin');
                },
              ),
            ),
          ),
          GetPage(
            name: '/other',
            page: () => const Scaffold(body: Text('other')),
          ),
          GetPage(
            name: AppRoutes.stockTransferDetail,
            page: () => const Scaffold(body: Text('transfer detail')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return origin;
  }

  ProductTransferController transfer({
    required FakeProductTransferService service,
    required FakeTransferStockService stocks,
    Future<void> Function()? changed,
  }) {
    final c = ProductTransferController(
      service: service,
      warehouseStockService: stocks,
      onStockChanged: changed ?? () async {},
    );
    addTearDown(c.onDelete.call);
    c.selectedFromWarehouse.value = 1;
    c.selectedToWarehouse.value = 2;
    c.transferItems.assignAll([
      {'product_id': 1, 'qty': 3},
    ]);
    return c;
  }

  testWidgets('late transfer edit never opens over a new route', (
    tester,
  ) async {
    final context = await host(tester);
    final service = FakeProductTransferService()..detailGate = Completer();
    final c = transfer(service: service, stocks: FakeTransferStockService());
    Get.put<WarehouseController>(TransferWarehouseController());
    Get.put<ProductTransferController>(c);
    // Get owns this controller's disposal after registration.
    final pending = c.editStockTransfer(context, transferJson(1));
    Get.toNamed('/other');
    await tester.pumpAndSettle();
    service.detailGate!.complete(transferJson(1));
    await tester.pumpAndSettle();
    expect(find.byType(StockTransferFormWidget), findsNothing);
    expect(Get.currentRoute, '/other');
    await pending;
  });

  testWidgets('late transfer detail never redirects a new route', (
    tester,
  ) async {
    await host(tester);
    final service = FakeProductTransferService()..detailGate = Completer();
    final c = transfer(service: service, stocks: FakeTransferStockService());
    final pending = c.gotoStockTransferDetail(transferJson(1));
    Get.toNamed('/other');
    await tester.pumpAndSettle();
    service.detailGate!.complete(transferJson(1));
    await pending;
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/other');
  });

  testWidgets('transfer preflight cancels when its origin route changes', (
    tester,
  ) async {
    final context = await host(tester);
    final service = FakeProductTransferService();
    final stocks = FakeTransferStockService()..gate = Completer();
    final c = transfer(service: service, stocks: stocks);
    final pending = c.onSaveStockTransfer(context);
    Get.toNamed('/other');
    await tester.pumpAndSettle();
    stocks.gate!.complete(stocks.records);
    await pending;
    expect(service.createCalls, 0);
    expect(c.totalDraftQuantity, 3);
    expect(Get.currentRoute, '/other');
  });

  testWidgets('committed transfer readback never pops another route', (
    tester,
  ) async {
    final context = await host(tester);
    final readback = Completer<void>();
    final entered = Completer<void>();
    final service = FakeProductTransferService();
    final c = transfer(
      service: service,
      stocks: FakeTransferStockService(),
      changed: () {
        entered.complete();
        return readback.future;
      },
    );
    final pending = c.onSaveStockTransfer(context);
    await entered.future;
    Get.toNamed('/other');
    await tester.pumpAndSettle();
    readback.complete();
    await pending;
    await tester.pumpAndSettle();
    expect(service.createCalls, 1);
    expect(c.formError.value, isEmpty);
    expect(Get.currentRoute, '/other');
  });

  testWidgets('stock edit keeps committed quantity when readback fails', (
    tester,
  ) async {
    final context = await host(tester);
    final service = stock.FakeWarehouseStockService();
    final c = WarehouseStockController(
      service: service,
      onStockChanged: () async {},
    );
    addTearDown(c.onDelete.call);
    c.onClearWarehouseStock();
    c.warehouseStockList.assignAll([stock.warehouseStockJson(1, qty: 10)]);
    c.editingStockId.value = 1;
    c.selectedWarehouse.value = '1';
    (c.productRows.single['product'] as RxnString).value = '1';
    (c.productRows.single['qty'] as TextEditingController).text = '7';
    service.failRead = true;
    await c.onUpdateWarehouseStock(1, context);
    expect(service.updateCalls, 1);
    expect(c.warehouseStockList.single['qty'], 7);
    expect(c.formError.value, isEmpty);
    expect(c.loadError.value, isNotEmpty);
  });

  for (final warehouseStock in [false, true]) {
    testWidgets(
      'delete opens one confirmation for warehouseStock=$warehouseStock',
      (tester) async {
        final context = await host(tester);
        final transfers = transfer(
          service: FakeProductTransferService(),
          stocks: FakeTransferStockService(),
        );
        final stocks = WarehouseStockController(
          service: stock.FakeWarehouseStockService(),
        );
        addTearDown(stocks.onDelete.call);
        Future<void> remove() => warehouseStock
            ? stocks.onDeleteWarehouseStock(1, context)
            : transfers.onDeleteStockTransfer(context, 1);
        await remove();
        await remove();
        await tester.pumpAndSettle();
        expect(
          find.byType(ConfirmDialogWidget, skipOffstage: false),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('committed stock form cannot repeat a write during dismissal', (
    tester,
  ) async {
    final context = await host(tester);
    late BuildContext formContext;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (value) {
          formContext = value;
          return const Dialog(child: Text('draft'));
        },
      ),
    );
    await tester.pumpAndSettle();
    final service = stock.FakeWarehouseStockService()..failRead = true;
    final c = WarehouseStockController(
      service: service,
      onStockChanged: () async {},
    );
    addTearDown(c.onDelete.call);
    c.onClearWarehouseStock();
    c.selectedWarehouse.value = '1';
    (c.productRows.single['product'] as RxnString).value = '1';
    (c.productRows.single['qty'] as TextEditingController).text = '3';
    final saving = c.onSaveWarehouseStock(formContext);
    await tester.pump();
    await c.onSaveWarehouseStock(formContext);
    await saving;
    expect(service.createCalls, 1);
    expect(c.formError.value, isEmpty);
    expect(c.loadError.value, isNotEmpty);
  });
}
