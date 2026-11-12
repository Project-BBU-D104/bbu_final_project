import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_card_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_table_widget.dart';
import 'package:get/get.dart';
import 'purchase_payment_test_support.dart';

void main() {
  setUp(setUpPurchasePaymentTests);
  tearDown(Get.reset);

  testWidgets('card handles missing relations and follows the theme', (
    tester,
  ) async {
    await pumpPurchasePaymentHost(
      tester,
      dark: true,
      home: const Scaffold(
        body: PurchasePaymentCardWidget(
          payment: {
            'id': 1,
            'payment_no': 'PP-1',
            'amount': 10,
            'purchase': null,
            'supplier': null,
            'payment_type': null,
            'currency': {'symbol': '\$'},
            'payment_date': null,
            'status': null,
          },
        ),
      ),
    );
    expect(find.text('PP-1'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card translates status and shows the invoice', (tester) async {
    await pumpPurchasePaymentHost(
      tester,
      home: Scaffold(
        body: PurchasePaymentCardWidget(payment: purchasePaymentJson(1)),
      ),
    );
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('PUR-3'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Supplier A'), findsOneWidget);
  });

  testWidgets('card reflows long Khmer text at large scale', (tester) async {
    await pumpPurchasePaymentHost(
      tester,
      size: const Size(360, 720),
      locale: const Locale('km', 'KH'),
      textScale: 2,
      home: Scaffold(
        body: PurchasePaymentCardWidget(
          payment: {...purchasePaymentJson(1), 'payment_no': 'ទូទាត់ ' * 12},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('table renders one row per payment', (tester) async {
    await pumpPurchasePaymentHost(
      tester,
      size: const Size(1440, 900),
      home: Scaffold(
        body: PurchasePaymentTableWidget(
          payments: [
            purchasePaymentJson(1),
            purchasePaymentJson(2, paymentNo: 'PP-2'),
          ],
        ),
      ),
    );
    expect(find.text('Payment No'), findsOneWidget);
    expect(find.text('PP-1'), findsOneWidget);
    expect(find.text('PP-2'), findsOneWidget);
    expect(find.text('\$40.00'), findsNWidgets(2));
  });
}
