import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_form_widget.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';
import 'stock_adjustment_test_support.dart';

void main() {
  setUp(setUpAdjustmentTests);
  tearDown(Get.reset);
  late StockAdjustmentController c;
  late FakeStockAdjustmentService service;
  setUp(() {
    bindAdjustmentOptions();
    service = FakeStockAdjustmentService();
    c = Get.put(
      StockAdjustmentController(
        service: service,
        warehouseStockService: FakeAdjustmentStockService(),
        currentUserId: () => 5,
        onStockChanged: () async {},
      ),
    );
  });
  testWidgets('adjustment missing fields show inline errors', (tester) async {
    await pumpAdjustmentHost(
      tester,
      home: const Scaffold(body: StockAdjustmentFormWidget()),
    );
    await tester.tap(find.text('Save'));
    expect(
      find.text(
        'Preview reverses the original movement before applying your changes.',
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(find.text('Please select a warehouse'), findsOneWidget);
    expect(find.text('Select a product'), findsOneWidget);
    expect(find.text('Please select an adjustment type'), findsOneWidget);
    expect(
      find.text('Enter a whole quantity greater than zero'),
      findsOneWidget,
    );
    expect(service.createCalls, 0);
    final warehouse = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).first,
    );
    expect(warehouse.focusNode!.hasFocus, true);
  });
  testWidgets(
    'valid edit shows corrected preview and optional reference reason',
    (tester) async {
      c.editingAdjustment.value = adjustmentJson(1);
      c.selectedWarehouse.value = '1';
      c.selectedProduct.value = '1';
      c.selectedAdjustmentType.value = 'increase';
      c.adjustmentQtyController.text = '4';
      // Live 10 minus original 3 plus draft 4.
      await c.loadCurrentQty();
      await pumpAdjustmentHost(
        tester,
        home: const Scaffold(
          body: StockAdjustmentFormWidget(stockAdjustmentId: 1),
        ),
      );
      expect(c.currentQtyController.text, '7');
      expect(c.newQtyController.text, '11');
      expect(c.validateDraft(), true);
      expect(find.byType(AppFormSection), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'stock failure disables submit and retry restores known preview',
    (tester) async {
      c.selectedWarehouse.value = '1';
      c.selectedProduct.value = '1';
      final stock = c.warehouseStockService as FakeAdjustmentStockService;
      stock.fail = true;
      await c.loadCurrentQty();
      await pumpAdjustmentHost(
        tester,
        home: const Scaffold(body: StockAdjustmentFormWidget()),
      );
      expect(find.text('Current stock unknown'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
            .onPressed,
        isNull,
      );
      stock.fail = false;
      await tester.ensureVisible(find.text('Retry'));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(c.currentQtyKnown.value, true);
      expect(c.currentQtyController.text, '10');
      expect(service.createCalls, 0);
    },
  );
  testWidgets(
    'saving blocks dismissal and changes then failure retains all draft fields',
    (tester) async {
      late BuildContext pageContext;
      await pumpAdjustmentHost(
        tester,
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const Scaffold();
          },
        ),
      );
      c.addStockAdjustment(pageContext);
      await tester.pumpAndSettle();
      c.selectedWarehouse.value = '1';
      c.selectedProduct.value = '1';
      c.selectedAdjustmentType.value = 'increase';
      c.adjustmentQtyController.text = '3';
      c.referenceController.text = 'keep ref';
      c.reasonController.text = 'keep reason';
      await c.loadCurrentQty();
      await tester.pumpAndSettle();
      service.writeGate = Completer();
      service.failWrite = true;
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(service.createCalls, 1);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, false);
      for (final button in tester.widgetList<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      )) {
        expect(button.onChanged, isNull);
      }
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(StockAdjustmentFormWidget), findsOneWidget);
      service.writeGate!.complete();
      await tester.pumpAndSettle();
      expect(c.referenceController.text, 'keep ref');
      expect(c.reasonController.text, 'keep reason');
      expect(c.adjustmentQtyController.text, '3');
      expect(
        find.text('Unable to save stock adjustment. Please try again.'),
        findsOneWidget,
      );
    },
  );
  testWidgets('committed save closes only form despite failed list readback', (
    tester,
  ) async {
    late BuildContext page;
    await pumpAdjustmentHost(
      tester,
      home: Builder(
        builder: (context) {
          page = context;
          return const Scaffold();
        },
      ),
      size: const Size(1440, 900),
    );
    c.addStockAdjustment(page);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    c.selectedWarehouse.value = '1';
    c.selectedProduct.value = '1';
    c.selectedAdjustmentType.value = 'increase';
    c.adjustmentQtyController.text = '3';
    await c.loadCurrentQty();
    await tester.pumpAndSettle();
    service.failGet = true;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(service.createCalls, 1);
    expect(find.byType(StockAdjustmentFormWidget), findsNothing);
    expect(
      c.loadError.value,
      'Unable to load stock adjustments. Please try again.',
    );
    expect(c.formError.value, isEmpty);
  });
  testWidgets(
    'successful edit submits corrected preview without derived fields',
    (tester) async {
      late BuildContext page;
      await pumpAdjustmentHost(
        tester,
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold();
          },
        ),
        size: const Size(1440, 900),
      );
      (c.warehouseStockService as FakeAdjustmentStockService).qty = 15;
      await c.editStockAdjustment(page, 1);
      await tester.pumpAndSettle();
      c.adjustmentQtyController.text = '4';
      c.referenceController.clear();
      c.reasonController.clear();
      await tester.pumpAndSettle();
      expect(c.currentQtyController.text, '12');
      expect(c.newQtyController.text, '16');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(service.updateCalls, 1);
      expect(service.payload, containsPair('qty', 4));
      expect(service.payload, containsPair('reference_no', ''));
      expect(service.payload, containsPair('reason', ''));
      expect(service.payload!.containsKey('previous_qty'), false);
      expect(service.payload!.containsKey('new_qty'), false);
      expect(find.byType(StockAdjustmentFormWidget), findsNothing);
    },
  );
  for (final dark in [false, true]) {
    for (final locale in [const Locale('en', 'US'), const Locale('km', 'KH')]) {
      for (final width in [390.0, 1024.0]) {
        testWidgets('form layout $dark $locale $width', (tester) async {
          await pumpAdjustmentHost(
            tester,
            home: const Scaffold(body: StockAdjustmentFormWidget()),
            size: Size(width, 900),
            dark: dark,
            locale: locale,
            textScale: 2,
            keyboardInset: 250,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
