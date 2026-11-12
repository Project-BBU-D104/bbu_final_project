import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/screen/purchase_payment/purchase_payment_screen.dart';
import 'package:frontend/screen/purchase_payment/widget/add_purchase_payment_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/edit_purchase_payment_widget.dart';
import 'package:get/get.dart';
import 'purchase_payment_test_support.dart';

Future<PurchasePaymentController> seed(
  WidgetTester tester,
  FakePurchasePaymentService service,
) async {
  final c = PurchasePaymentController(
    service: service,
    purchaseCtr: FakePurchaseController(),
    paymentTypeCtr: FakePaymentTypeController(
      types: [
        {'id': 2, 'name': 'Cash'},
      ],
    ),
    currencyCtr: FakeCurrencyController(
      currencies: [
        {'id': 1, 'name': 'USD', 'symbol': '\$'},
      ],
    ),
  );
  await c.onGetPaymentList();
  Get.put<PurchasePaymentController>(c);
  await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
  await tester.pumpAndSettle();
  return c;
}

Future<void> fillValid(PurchasePaymentController c) async {
  c.selectedPurchaseId.value = 3;
  c.selectedPaymentTypeId.value = 2;
  c.selectedCurrencyId.value = 1;
  c.amountCtrl.text = '40';
  c.noteCtrl.text = ' First ';
  c.purchaseDate.value = DateTime.utc(2026, 11, 9);
}

void main() {
  setUp(setUpPurchasePaymentTests);
  tearDown(Get.reset);

  testWidgets('blank required fields never write and show inline errors', (
    tester,
  ) async {
    final s = FakePurchasePaymentService();
    final c = await seed(tester, s);
    c.addPurchasePayment(tester.element(find.byType(PurchasePaymentScreen)));
    await tester.pumpAndSettle();
    c.amountCtrl.clear();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
    expect(find.text('Please select a purchase'), findsOneWidget);
    expect(find.text('Please select a payment type'), findsOneWidget);
    expect(find.text('Please select a currency'), findsOneWidget);
    expect(find.text('Enter a valid amount'), findsOneWidget);
  });

  testWidgets('payload keeps the purchase payment contract', (tester) async {
    final s = FakePurchasePaymentService();
    final c = await seed(tester, s);
    c.addPurchasePayment(tester.element(find.byType(PurchasePaymentScreen)));
    await tester.pumpAndSettle();
    await fillValid(c);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(s.lastCreatedData, {
      'payment_no': '',
      'purchase_id': 3,
      'supplier_id': 9,
      'payment_type_id': 2,
      'currency_id': 1,
      'amount': 40.0,
      'payment_date': '2026-11-09T00:00:00.000Z',
      'status': 'completed',
      'note': 'First',
    });
  });

  testWidgets('write failure preserves the draft and shows an error', (
    tester,
  ) async {
    final s = FakePurchasePaymentService()..failWrite = true;
    final c = await seed(tester, s);
    c.addPurchasePayment(tester.element(find.byType(PurchasePaymentScreen)));
    await tester.pumpAndSettle();
    await fillValid(c);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchasePaymentWidget), findsOneWidget);
    expect(
      find.text('Unable to save purchase payment. Please try again.'),
      findsOneWidget,
    );
    expect(c.amountCtrl.text, '40');
    expect(c.noteCtrl.text, ' First ');
    expect(s.createCalls, 1);
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = FakePurchasePaymentService()..createGate = Completer();
    final c = await seed(tester, s);
    c.addPurchasePayment(tester.element(find.byType(PurchasePaymentScreen)));
    await tester.pumpAndSettle();
    await fillValid(c);
    final context = tester.element(find.byType(AddPurchasePaymentWidget));
    c.onSavePurchasePayment(context);
    c.onSavePurchasePayment(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddPurchasePaymentWidget), findsOneWidget);
    s.createGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchasePaymentWidget), findsNothing);
  });

  testWidgets('edit prefills fields and update sends the contract', (
    tester,
  ) async {
    final s = FakePurchasePaymentService(
      payments: [purchasePaymentJson(11, paymentNo: 'PP-11')],
    );
    final c = await seed(tester, s);
    await c.editPurchasePayment(
      tester.element(find.byType(PurchasePaymentScreen)),
      s.payments.first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(EditPurchasePaymentWidget), findsOneWidget);
    expect(c.paymentNoCtrl.text, 'PP-11');
    expect(c.selectedPurchaseId.value, 3);
    expect(c.selectedPaymentTypeId.value, 2);
    expect(c.selectedCurrencyId.value, 1);
    expect(find.text('PUR-3 - Due: 60.0'), findsOneWidget);
    c.amountCtrl.text = '45';
    await tester.ensureVisible(find.text('Update'));
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(s.lastUpdatedData?['amount'], 45.0);
    expect(s.lastUpdatedData?['payment_no'], 'PP-11');
  });

  testWidgets('wide screens host the form in a dialog', (tester) async {
    final c = await seed(tester, FakePurchasePaymentService());
    await pumpPurchasePaymentHost(
      tester,
      home: PurchasePaymentScreen(),
      size: const Size(1440, 900),
    );
    c.addPurchasePayment(tester.element(find.byType(PurchasePaymentScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });
}
