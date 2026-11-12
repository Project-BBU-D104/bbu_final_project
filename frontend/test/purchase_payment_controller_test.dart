import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:get/get.dart';
import 'purchase_payment_test_support.dart';

void main() {
  setUp(setUpPurchasePaymentTests);
  tearDown(Get.reset);

  test('loads payments', () async {
    final c = PurchasePaymentController(
      service: FakePurchasePaymentService(),
      purchaseCtr: FakePurchaseController(),
      paymentTypeCtr: FakePaymentTypeController(types: []),
      currencyCtr: FakeCurrencyController(currencies: []),
    );
    await c.onGetPaymentList();
    expect(c.purchasePaymentList, hasLength(2));
    expect(c.loadError.value, isEmpty);
  });

  test('failed refresh keeps rows and exposes retry copy', () async {
    final s = FakePurchasePaymentService();
    final c = PurchasePaymentController(
      service: s,
      purchaseCtr: FakePurchaseController(),
      paymentTypeCtr: FakePaymentTypeController(types: []),
      currencyCtr: FakeCurrencyController(currencies: []),
    );
    await c.onGetPaymentList();
    s.failGet = true;
    await c.onRefresh();
    expect(
      c.loadError.value,
      'Unable to load purchase payments. Please try again.',
    );
    expect(c.purchasePaymentList, hasLength(2));
  });

  test('refresh keeps the current search query', () async {
    final s = FakePurchasePaymentService(
      payments: [
        purchasePaymentJson(11, paymentNo: 'PP-ALPHA'),
        purchasePaymentJson(12, paymentNo: 'PP-BETA'),
      ],
    );
    final c = PurchasePaymentController(
      service: s,
      purchaseCtr: FakePurchaseController(),
      paymentTypeCtr: FakePaymentTypeController(types: []),
      currencyCtr: FakeCurrencyController(currencies: []),
    );
    await c.onGetPaymentList();
    c.searchPayments(' alpha ');
    await c.onRefresh();
    expect(c.searchPaymentList.map((p) => p['payment_no']), ['PP-ALPHA']);
  });

  testWidgets('a save already in flight is ignored', (tester) async {
    final s = FakePurchasePaymentService();
    final c = PurchasePaymentController(
      service: s,
      purchaseCtr: FakePurchaseController(),
      paymentTypeCtr: FakePaymentTypeController(types: []),
      currencyCtr: FakeCurrencyController(currencies: []),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    c.isSaving.value = true;
    await c.onSavePurchasePayment(tester.element(find.byType(SizedBox)));
    await c.onUpdatePurchasePayment(tester.element(find.byType(SizedBox)));
    expect(s.createCalls, 0);
    expect(s.updateCalls, 0);
  });
}
