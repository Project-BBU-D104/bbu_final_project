import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/screen/purchases/purchases_screen.dart';
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

  Future<PurchaseController> seedPurchase([
    FakePurchaseService? service,
  ]) async {
    final c = PurchaseController(service: service ?? FakePurchaseService());
    await c.onGetPurchaseList();
    return Get.put<PurchaseController>(c);
  }

  testWidgets('list adapts cards and table to usable width', (tester) async {
    await seedPurchase();
    await pumpPurchaseHost(
      tester,
      home: PurchasesScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(PurchaseCardWidget), findsNWidgets(2));
    expect(find.byType(PurchaseTableWidget), findsNothing);
    await pumpPurchaseHost(
      tester,
      home: PurchasesScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(PurchaseTableWidget), findsOneWidget);
  });

  testWidgets('loading, error, empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seedPurchase();
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.loadError.value = 'Unable to load purchases. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchPurchase('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching purchases'), findsOneWidget);
    c.purchaseList.clear();
    c.searchPurchase('');
    await tester.pumpAndSettle();
    expect(find.text('No purchases yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-purchase')), findsOneWidget);
  });

  testWidgets('retry keeps the active search query', (tester) async {
    final c = await seedPurchase();
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    final search = Get.find<SearchController>();
    search.keyword.value = 'alpha';
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.searchPurchaseList.length, 1);
    await c.onRefresh();
    await tester.pumpAndSettle();
    expect(c.searchPurchaseList.length, 1);
  });

  testWidgets('long Khmer content reflows in both themes', (tester) async {
    final c = await seedPurchase();
    c.purchaseList[0] = {
      ...c.purchaseList.first,
      'invoice_no': 'វិក្កយបត្រ ' * 12,
    };
    c.searchPurchase('');
    for (final dark in [false, true]) {
      await pumpPurchaseHost(
        tester,
        home: PurchasesScreen(),
        size: const Size(360, 720),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
