import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/screen/purchases/purchases_screen.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/screen/purchases/widget/edit_purchase_widget.dart';
import 'package:get/get.dart';
import 'purchase_test_support.dart';

void main() {
  setUp(setUpPurchaseTests);
  tearDown(Get.reset);

  Future<PurchaseController> seed(
    WidgetTester tester,
    FakePurchaseService service,
  ) async {
    final c = PurchaseController(service: service);
    await c.onGetPurchaseList();
    Get.put<PurchaseController>(c);
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    await tester.pumpAndSettle();
    return c;
  }

  void fillPurchase(
    PurchaseController c, {
    String tax = '0',
    String paid = '0',
  }) {
    c.invoiceCtrl.text = 'INV-9';
    c.selectedWarehouse.value = 1;
    c.selectedSupplier.value = 1;
    c.items.first
      ..product.value = {'id': 1, 'name': 'Widget'}
      ..qtyCtrl.text = '2'
      ..costCtrl.text = '5';
    c.taxCtrl.text = tax;
    c.paidCtrl.text = paid;
  }

  testWidgets('blank required fields never write and show inline errors', (
    tester,
  ) async {
    final s = FakePurchaseService();
    final c = await seed(tester, s);
    c.addPurchase(tester.element(find.byType(PurchasesScreen)));
    await tester.pumpAndSettle();
    c.invoiceCtrl.clear();
    c.items.first.qtyCtrl.clear();
    c.items.first.costCtrl.clear();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
    expect(find.text('Invoice number is required'), findsOneWidget);
    expect(find.text('Please select a warehouse'), findsOneWidget);
    expect(find.text('Please select a supplier'), findsOneWidget);
    expect(find.text('Select a product'), findsOneWidget);
    expect(find.text('Enter a quantity greater than zero'), findsOneWidget);
    expect(find.text('Enter a cost greater than zero'), findsOneWidget);
  });

  testWidgets('payload keeps the purchase contract', (tester) async {
    final s = FakePurchaseService();
    final c = await seed(tester, s);
    c.addPurchase(tester.element(find.byType(PurchasesScreen)));
    await tester.pumpAndSettle();
    fillPurchase(c, tax: '1', paid: '2');
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final data = s.lastCreatedData!;
    expect(data['supplier_id'], 1);
    expect(data['warehouse_id'], 1);
    expect(data['invoice_no'], 'INV-9');
    expect(data['user_id'], 5);
    expect(data['purchase_date'], c.purchaseDate.value.toIso8601String());
    expect(data['subtotal'], 10.0);
    expect(data['tax_amount'], 1.0);
    expect(data['discount_amount'], 0.0);
    expect(data['total_amount'], 11.0);
    expect(data['paid_amount'], 2.0);
    expect(data['due_amount'], 9.0);
    expect(data['payment_status'], 'partial');
    expect(data['items'], [
      {'product_id': 1, 'qty': 2.0, 'cost_price': 5.0, 'subtotal': 10.0},
    ]);
  });

  testWidgets('write failure preserves the draft and shows an error', (
    tester,
  ) async {
    final s = FakePurchaseService()..failWrite = true;
    final c = await seed(tester, s);
    c.addPurchase(tester.element(find.byType(PurchasesScreen)));
    await tester.pumpAndSettle();
    fillPurchase(c);
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchaseWidget), findsOneWidget);
    expect(
      find.text('Unable to save purchase. Please try again.'),
      findsOneWidget,
    );
    expect(c.invoiceCtrl.text, 'INV-9');
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = DelayedPurchaseService()..createGate = Completer();
    final c = await seed(tester, s);
    c.addPurchase(tester.element(find.byType(PurchasesScreen)));
    await tester.pumpAndSettle();
    fillPurchase(c);
    await tester.pump();
    final context = tester.element(find.byType(AddPurchaseWidget));
    c.createPurchase(context);
    c.createPurchase(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddPurchaseWidget), findsOneWidget);
    s.createGate!.complete({'id': 3});
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchaseWidget), findsNothing);
  });

  testWidgets('edit prefills fields and update omits user_id', (tester) async {
    final s = FakePurchaseService();
    final c = await seed(tester, s);
    await c.editPurchase(tester.element(find.byType(PurchasesScreen)), 1);
    await tester.pumpAndSettle();
    expect(find.byType(EditPurchaseWidget), findsOneWidget);
    expect(c.invoiceCtrl.text, 'INV-1');
    expect(c.items, hasLength(1));
    expect(find.text('Subtotal'), findsOneWidget);
    c.invoiceCtrl.text = 'INV-UPDATED';
    await tester.ensureVisible(find.text('Update'));
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(s.lastUpdatedData!.containsKey('user_id'), isFalse);
    expect(s.lastUpdatedData!['invoice_no'], 'INV-UPDATED');
  });

  testWidgets('wide screens host the form in a dialog', (tester) async {
    final c = await seed(tester, FakePurchaseService());
    await pumpPurchaseHost(
      tester,
      home: PurchasesScreen(),
      size: const Size(1440, 900),
    );
    c.addPurchase(tester.element(find.byType(PurchasesScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });
}
