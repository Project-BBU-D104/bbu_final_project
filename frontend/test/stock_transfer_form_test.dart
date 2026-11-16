import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_form_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'stock_transfer_test_support.dart';

void main() {
  late ProductTransferController c;
  late FakeTransferStockService stocks;
  late FakeProductTransferService service;
  setUp(() {
    initTransferEnvironment();
    Get.testMode = true;
    stocks = FakeTransferStockService();
    service = FakeProductTransferService();
    c = Get.put(
      ProductTransferController(
        service: service,
        warehouseStockService: stocks,
        onStockChanged: () async {},
      ),
    );
    final warehouses = TransferWarehouseController();
    warehouses.warehouseList.assignAll([
      {'id': 1, 'name': 'Source'},
      {'id': 2, 'name': 'Destination'},
      {'id': 3, 'name': 'Other'},
    ]);
    Get.put<WarehouseController>(warehouses);
  });
  tearDown(() => Get.reset());
  Future<void> host(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
    bool dark = false,
    String language = 'en',
    bool edit = false,
    double inset = 0,
  }) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: Locale(language, language == 'en' ? 'US' : 'KH'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 900),
              textScaler: TextScaler.linear(scale),
              viewInsets: EdgeInsets.only(bottom: inset),
            ),
            child: StockTransferFormWidget(
              stockTransfer: edit ? c.editingTransfer.value : null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void draft() {
    c.selectedFromWarehouse.value = 1;
    c.selectedToWarehouse.value = 2;
    c.selectedProduct.value = 1;
    c.quantityController.text = '3';
    c.addDraftItem();
  }

  testWidgets('transfer fields show inline required errors', (tester) async {
    await host(tester);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Please select a warehouse'), findsWidgets);
    expect(find.text('Choose different warehouses'), findsOneWidget);
    c.selectedFromWarehouse.value = 1;
    c.selectedToWarehouse.value = 2;
    c.addDraftItem();
    await tester.pump();
    expect(find.text('Select a product'), findsOneWidget);
    c.selectedProduct.value = 1;
    c.quantityController.text = '1.5';
    c.addDraftItem();
    await tester.pump();
    expect(
      find.text('Enter a whole quantity greater than zero'),
      findsOneWidget,
    );
    c.validateDraft();
    await tester.pump();
    expect(find.text('Add at least one product'), findsOneWidget);
  });
  testWidgets('source change flags retained rows', (tester) async {
    await host(tester);
    draft();
    c.selectFromWarehouse(3);
    await tester.pump();
    expect(c.totalDraftQuantity, 3);
    expect(find.text('Quantity exceeds available stock.'), findsOneWidget);
    expect(c.validateDraft(), false);
  });
  testWidgets('stock failure retry retains transfer', (tester) async {
    await host(tester);
    draft();
    stocks.fail = true;
    await c.onGetWarehouseStock();
    await tester.pump();
    expect(
      find.text('Unable to load current stock. Please try again.'),
      findsOneWidget,
    );
    stocks.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(c.stockError.value, isEmpty);
    expect(c.totalDraftQuantity, 3);
  });
  testWidgets('saving blocks date changes row actions and dismissal', (
    tester,
  ) async {
    await c.onGetWarehouseStock();
    draft();
    await host(tester);
    stocks.gate = Completer<dynamic>();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    final before = c.selectedDate.value;
    c.removeDraftItem(0);
    c.selectFromWarehouse(3);
    c.onClear();
    expect(c.totalDraftQuantity, 3);
    expect(c.selectedFromWarehouse.value, 1);
    expect(c.selectedDate.value, before);
    expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, false);
    stocks.gate!.complete([stockJson(qty: 1)]);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
  });
  testWidgets(
    'transfer edit preloads date and all items including unavailable products',
    (tester) async {
      await host(tester);
      final original = transferJson(1, qty: 5);
      (original['product_transfer_items'] as List).add({
        'product_id': 99,
        'product': null,
        'qty': 2,
      });
      service.records = [original];
      final pending = c.editStockTransfer(
        tester.element(find.byType(StockTransferFormWidget)),
        original,
      );
      await tester.pumpAndSettle();
      expect(c.selectedFromWarehouse.value, 1);
      expect(c.selectedToWarehouse.value, 2);
      expect(c.productTransferRefController.text, 'TR-1');
      expect(c.transferItems, hasLength(2));
      expect(
        c.selectedDate.value,
        DateTime.parse(original['transfer_date']).toLocal(),
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Product #99'),
        ),
        findsOneWidget,
      );
      expect(c.validateDraft(), false);
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      await pending;
    },
  );
  testWidgets('Khmer draft validation renders translated message', (
    tester,
  ) async {
    await host(tester, language: 'km');
    c.validateDraft();
    await tester.pump();
    expect(find.text('ជ្រើសរើសឃ្លាំងផ្សេងគ្នា'), findsOneWidget);
  });
  for (final dark in [false, true]) {
    for (final language in ['en', 'km']) {
      for (final width in [390.0, 1024.0]) {
        testWidgets(
          'form layout $dark $language $width with long draft keyboard and large text',
          (tester) async {
            await c.onGetWarehouseStock();
            c.selectedFromWarehouse.value = 1;
            c.selectedToWarehouse.value = 2;
            c.transferItems.assignAll(
              List.generate(
                35,
                (i) => {
                  'product_id': i + 1,
                  'product': {'name': 'អង្ករផលិតផលឈ្មោះវែង $i'},
                  'qty': 3,
                },
              ),
            );
            await host(
              tester,
              width: width,
              scale: 2,
              dark: dark,
              language: language,
              inset: 300,
            );
            await tester.ensureVisible(find.text('Save'.tr));
            await tester.pumpAndSettle();
            expect(find.text('Save'.tr), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
