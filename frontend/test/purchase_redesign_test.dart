import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_card_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_table_widget.dart';
import 'package:get/get.dart';
import 'purchase_test_support.dart';

void main() {
  setUp(setUpPurchaseTests);
  tearDown(Get.reset);

  testWidgets('card handles missing supplier and follows the theme', (
    tester,
  ) async {
    await pumpPurchaseHost(
      tester,
      dark: true,
      home: const Scaffold(
        body: PurchaseCardWidget(
          purchase: {
            'id': 1,
            'invoice_no': 'INV-1',
            'supplier': null,
            'purchase_date': null,
            'status': null,
            'total_amount': 10,
            'paid_amount': 2,
            'due_amount': 8,
          },
        ),
      ),
    );
    expect(find.text('INV-1'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card translates payment status', (tester) async {
    await pumpPurchaseHost(
      tester,
      home: Scaffold(
        body: PurchaseCardWidget(
          purchase: {
            ...purchaseJson(1, paymentStatus: 'partial', paid: 2, due: 8),
          },
        ),
      ),
    );
    expect(find.text('Partial'), findsOneWidget);
  });

  testWidgets('card reflows long Khmer text at large scale', (tester) async {
    await pumpPurchaseHost(
      tester,
      size: const Size(360, 720),
      locale: const Locale('km', 'KH'),
      textScale: 2,
      home: Scaffold(
        body: PurchaseCardWidget(
          purchase: {...purchaseJson(1), 'invoice_no': 'វិក្កយបត្រ ' * 12},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('table renders one row per purchase', (tester) async {
    Get.put<PurchaseController>(
      PurchaseController(service: FakePurchaseService()),
    );
    await pumpPurchaseHost(
      tester,
      size: const Size(1440, 900),
      home: Scaffold(
        body: PurchaseTableWidget(
          purchases: [
            purchaseJson(1),
            purchaseJson(2, invoiceNo: 'INV-2'),
          ],
        ),
      ),
    );
    expect(find.text('Invoice'), findsOneWidget);
    expect(find.text('INV-1'), findsOneWidget);
    expect(find.text('INV-2'), findsOneWidget);
    // Total and Due are both 10.00 in each of the two rows.
    expect(find.text('\$10.00'), findsNWidgets(4));
  });
}
