import 'dart:async';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/warehouse_stock_form_widget.dart';
import 'warehouse_stock_test_support.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost');
    Get.put<WarehouseController>(StockWarehouseController());
    Get.put<ProductController>(StockProductController());
  });
  tearDown(() => Get.reset());
  testWidgets(
    'stock lookup leaves the shared warehouse query and records consistent',
    (tester) async {
      final warehouse = Get.find<WarehouseController>();
      warehouse.warehouseList.assignAll([
        {'id': 9, 'name': 'Keep'},
      ]);
      warehouse.searchWarehouse('Keep');
      Get.put(WarehouseStockController(service: FakeWarehouseStockService()));
      await pumpWarehouseStockHost(
        tester,
        const Scaffold(body: WarehouseStockFormWidget()),
      );
      expect(warehouse.searchQuery.value, 'Keep');
      expect(warehouse.warehouseList.single['id'], 9);
      expect(warehouse.searchWarehouseList.single['id'], 9);
    },
  );
  testWidgets('stock edit has one row and no add/remove controls', (
    tester,
  ) async {
    final c = WarehouseStockController(service: FakeWarehouseStockService());
    Get.put<WarehouseStockController>(c);
    c.editingStockId.value = 1;
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: WarehouseStockFormWidget(warehouseStockId: 1)),
      ),
    );
    await tester.pump();
    expect(c.productRows.length, 1);
    expect(find.byKey(const Key('stock-add-row')), findsNothing);
    expect(find.byTooltip('Remove product'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stock lookup failure offers retry and retains selection', (
    tester,
  ) async {
    final warehouse =
        Get.find<WarehouseController>() as StockWarehouseController;
    warehouse.service.fail = true;
    final c = Get.put(
      WarehouseStockController(service: FakeWarehouseStockService()),
    );
    c.selectedWarehouse.value = '1';
    (c.productRows.single['qty'] as TextEditingController).text = '7';
    await pumpWarehouseStockHost(
      tester,
      const Scaffold(body: WarehouseStockFormWidget()),
    );
    expect(find.text('Retry'), findsOneWidget);
    warehouse.service.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsNothing);
    expect(c.selectedWarehouse.value, '1');
    expect((c.productRows.single['qty'] as TextEditingController).text, '7');
  });
  testWidgets('stock add serializes two integer rows', (tester) async {
    final service = FakeWarehouseStockService();
    final c = Get.put(WarehouseStockController(service: service));
    c.selectedWarehouse.value = '1';
    c.addProductRow();
    for (var i = 0; i < 2; i++) {
      (c.productRows[i]['product'] as RxnString).value = '${i + 1}';
      (c.productRows[i]['qty'] as TextEditingController).text = '$i';
    }
    await pumpWarehouseStockHost(
      tester,
      const Scaffold(body: WarehouseStockFormWidget()),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(service.lastCreatedData, {
      'warehouse_id': 1,
      'items': [
        {'product_id': 1, 'qty': 0},
        {'product_id': 2, 'qty': 1},
      ],
    });
  });
  testWidgets('stock add validates each row', (tester) async {
    final service = FakeWarehouseStockService();
    Get.put(WarehouseStockController(service: service));
    await pumpWarehouseStockHost(
      tester,
      const Scaffold(body: WarehouseStockFormWidget()),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Please select a warehouse'), findsWidgets);
    expect(find.text('Select a product'), findsOneWidget);
    expect(find.text('Enter a whole quantity of zero or more'), findsOneWidget);
    expect(service.createCalls, 0);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Warehouse');
  });
  testWidgets('saving blocks close and row edits', (tester) async {
    final service = FakeWarehouseStockService()..writeGate = Completer();
    final c = Get.put(WarehouseStockController(service: service));
    c.selectedWarehouse.value = '1';
    (c.productRows.single['product'] as RxnString).value = '1';
    (c.productRows.single['qty'] as TextEditingController).text = '3';
    await pumpWarehouseStockHost(
      tester,
      const Scaffold(body: WarehouseStockFormWidget()),
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Close',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('stock-add-row')));
    await tester.pump();
    expect(c.productRows.length, 1);
    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, false);
    service.writeGate!.complete();
    await tester.pumpAndSettle();
  });
  for (final width in [390.0, 1024.0]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        testWidgets('stock form layout $width dark=$dark khmer=$khmer', (
          tester,
        ) async {
          Get.put(
            WarehouseStockController(service: FakeWarehouseStockService()),
          );
          await pumpWarehouseStockHost(
            tester,
            const Scaffold(body: WarehouseStockFormWidget()),
            width: width,
            dark: dark,
            khmer: khmer,
            scale: 2,
            keyboardInset: 300,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
