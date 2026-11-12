import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/screen/purchase_payment/purchase_payment_screen.dart';
import 'package:frontend/screen/purchase_payment/widget/edit_purchase_payment_widget.dart';
import 'package:get/get.dart';
import 'purchase_payment_test_support.dart';

class Harness {
  Harness({
    required this.ctr,
    required this.paymentService,
    required this.purchaseCtr,
  });

  final PurchasePaymentController ctr;
  final FakePurchasePaymentService paymentService;
  final FakePurchaseController purchaseCtr;
}

Future<Harness> pumpScreen(
  WidgetTester tester, {
  required List<Map<String, dynamic>> payments,
  List<Map<String, dynamic>>? purchases,
}) async {
  final paymentService = FakePurchasePaymentService(payments: payments);
  final purchaseCtr = FakePurchaseController(
    purchases: purchases ?? [purchaseFixture()],
  );
  final ctr = PurchasePaymentController(
    service: paymentService,
    purchaseCtr: purchaseCtr,
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
  Get.put<PurchasePaymentController>(ctr);

  await tester.pumpWidget(GetMaterialApp(home: PurchasePaymentScreen()));
  await tester.pumpAndSettle();
  await ctr.onGetPaymentList();
  await tester.pumpAndSettle();

  return Harness(
    ctr: ctr,
    paymentService: paymentService,
    purchaseCtr: purchaseCtr,
  );
}

Future<void> openEdit(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
}

Future<void> tapUpdate(WidgetTester tester) async {
  final finder = find.widgetWithText(FilledButton, 'Update');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> closeToasts(WidgetTester tester) async {
  Get.closeAllSnackbars();
  await tester.pumpAndSettle();
}

void main() {
  setUp(setUpPurchasePaymentTests);

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'edit prefills identity and keeps a fully paid purchase visible',
    (tester) async {
      final harness = await pumpScreen(
        tester,
        payments: [
          purchasePaymentJson(
            11,
            paymentNo: 'PP-11',
            amount: 40.0,
            purchaseDue: 0.0,
          ),
        ],
        purchases: [purchaseFixture(due: 0.0)],
      );

      await openEdit(tester);

      expect(find.byType(EditPurchasePaymentWidget), findsOneWidget);
      expect(harness.ctr.editingPaymentId.value, 11);
      expect(harness.ctr.selectedPurchaseId.value, 3);
      expect(harness.ctr.selectedPaymentTypeId.value, 2);
      expect(harness.ctr.selectedCurrencyId.value, 1);
      expect(harness.ctr.paymentNoCtrl.text, 'PP-11');
      expect(double.parse(harness.ctr.amountCtrl.text), 40.0);
      expect(harness.ctr.paymentStatus.value, 'completed');
      expect(find.text('PUR-3 - Due: 0.0'), findsOneWidget);
      expect(harness.purchaseCtr.refreshCalls, greaterThan(0));
    },
  );

  testWidgets('update sends the full payload and refreshes both lists', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [purchasePaymentJson(11, paymentNo: 'PP-11')],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '75.0';
    harness.ctr.noteCtrl.text = 'Updated';
    harness.ctr.purchaseDate.value = DateTime.utc(2026, 11, 9);
    await tester.pump();

    final paymentsBefore = harness.paymentService.getPaymentsCalls;
    final purchasesBefore = harness.purchaseCtr.refreshCalls;
    await tapUpdate(tester);

    expect(harness.paymentService.updateCalls, 1);
    expect(harness.paymentService.lastUpdatedData, {
      'payment_no': 'PP-11',
      'purchase_id': 3,
      'supplier_id': 9,
      'payment_type_id': 2,
      'currency_id': 1,
      'amount': 75.0,
      'payment_date': '2026-11-09T00:00:00.000Z',
      'status': 'completed',
      'note': 'Updated',
    });
    expect(
      harness.paymentService.getPaymentsCalls,
      greaterThan(paymentsBefore),
    );
    expect(harness.purchaseCtr.refreshCalls, greaterThan(purchasesBefore));

    await closeToasts(tester);
  });

  testWidgets('completed payment allows due plus original amount', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [
        purchasePaymentJson(
          11,
          paymentNo: 'PP-11',
          amount: 40.0,
          status: 'completed',
        ),
      ],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '100';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 1);

    await closeToasts(tester);
  });

  testWidgets('completed payment rejects more than due plus original amount', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [
        purchasePaymentJson(
          11,
          paymentNo: 'PP-11',
          amount: 40.0,
          status: 'completed',
        ),
      ],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '100.01';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 0);
    expect(find.byType(EditPurchasePaymentWidget), findsOneWidget);

    await closeToasts(tester);
  });

  testWidgets('pending payment does not add the original amount', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [
        purchasePaymentJson(
          11,
          paymentNo: 'PP-11',
          amount: 40.0,
          status: 'pending',
        ),
      ],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '60';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 1);

    await closeToasts(tester);
  });

  testWidgets('pending payment rejects one cent over the purchase due', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [
        purchasePaymentJson(
          11,
          paymentNo: 'PP-11',
          amount: 40.0,
          status: 'pending',
        ),
      ],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '60.01';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 0);

    await closeToasts(tester);
  });

  testWidgets('edit ceiling uses the refreshed purchase balance', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [
        purchasePaymentJson(
          11,
          paymentNo: 'PP-11',
          amount: 40.0,
          status: 'completed',
        ),
      ],
      purchases: [purchaseFixture(due: 10.0)],
    );

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '50.01';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 0);

    harness.ctr.amountCtrl.text = '50';
    await tester.pump();
    await tapUpdate(tester);
    expect(harness.paymentService.updateCalls, 1);
    expect(harness.paymentService.lastUpdatedData?['amount'], 50.0);

    await closeToasts(tester);
  });

  testWidgets('update failure keeps the sheet open and resets isSaving', (
    tester,
  ) async {
    final harness = await pumpScreen(
      tester,
      payments: [purchasePaymentJson(11, paymentNo: 'PP-11')],
    );
    harness.paymentService.failWrite = true;

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '75.0';
    await tester.pump();
    await tapUpdate(tester);

    expect(harness.ctr.isSaving.value, isFalse);
    expect(find.byType(EditPurchasePaymentWidget), findsOneWidget);
    expect(harness.paymentService.updateCalls, 0);

    await closeToasts(tester);
  });

  testWidgets(
    'delete cancels without a call and confirms without leaving screen',
    (tester) async {
      final harness = await pumpScreen(
        tester,
        payments: [purchasePaymentJson(11, paymentNo: 'PP-11')],
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(harness.paymentService.deleteCalls, 0);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      final purchasesBefore = harness.purchaseCtr.refreshCalls;
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      expect(harness.paymentService.deleteCalls, 1);
      expect(harness.purchaseCtr.refreshCalls, greaterThan(purchasesBefore));
      expect(find.byType(PurchasePaymentScreen), findsOneWidget);

      await closeToasts(tester);
    },
  );

  testWidgets('two rapid updates make one request', (tester) async {
    final harness = await pumpScreen(
      tester,
      payments: [purchasePaymentJson(11, paymentNo: 'PP-11')],
    );
    harness.paymentService.updateGate = Completer();

    await openEdit(tester);
    harness.ctr.amountCtrl.text = '75.0';
    await tester.pump();

    final ctx = tester.element(find.byType(EditPurchasePaymentWidget));
    final first = harness.ctr.onUpdatePurchasePayment(ctx);
    final second = harness.ctr.onUpdatePurchasePayment(ctx);
    harness.paymentService.updateGate!.complete();
    await tester.pump();
    await Future.wait([first, second]);
    await tester.pumpAndSettle();

    expect(harness.paymentService.updateCalls, 1);
    expect(harness.ctr.isSaving.value, isFalse);

    await closeToasts(tester);
  });
}
