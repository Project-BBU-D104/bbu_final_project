import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/screen/purchases/purchases_screen.dart';
import 'package:frontend/screen/purchases/widget/purchase_card_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_detail_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_table_widget.dart';
import 'package:frontend/themes/app_theme.dart';
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

  testWidgets('table keeps bounded columns with long text', (tester) async {
    Get.put<PurchaseController>(
      PurchaseController(service: FakePurchaseService()),
    );
    await pumpPurchaseHost(
      tester,
      size: const Size(1440, 900),
      home: Scaffold(
        body: PurchaseTableWidget(
          purchases: [
            purchaseJson(
              1,
              invoiceNo: 'INV-${'X' * 200}',
              supplierName: 'S' * 200,
            ),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(DataTable)).width, lessThan(1500));
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

  testWidgets('detail renders no-data state without arguments', (tester) async {
    await seedPurchase();
    await pumpPurchaseHost(tester, home: PurchaseDetailWidget());
    expect(find.text('No purchase data found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail shows items, totals, and real values', (tester) async {
    final c = await seedPurchase();
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseDetailWidget), findsOneWidget);
    expect(find.text('INV-1'), findsWidgets);
    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('\$10.00'), findsWidgets);
    expect(find.text('No items in this purchase'), findsNothing);
  });

  testWidgets('delete from detail closes it and refreshes the list', (
    tester,
  ) async {
    final s = FakePurchaseService();
    final c = await seedPurchase(s);
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Do you want to delete this purchase?'), findsOneWidget);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 1);
    expect(find.byType(PurchaseDetailWidget), findsNothing);
    expect(find.byType(PurchasesScreen), findsOneWidget);
    expect(c.purchaseList.length, 1);
  });

  testWidgets('failed delete keeps the detail open', (tester) async {
    final s = FakePurchaseService()..failWrite = true;
    final c = await seedPurchase(s);
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseDetailWidget), findsOneWidget);
    expect(c.purchaseList.length, 2);
    expect(
      find.text('Unable to delete purchase. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('edit from detail refreshes the displayed values', (
    tester,
  ) async {
    final s = FakePurchaseService();
    final c = await seedPurchase(s);
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Edit'));
    await tester.pumpAndSettle();
    c.invoiceCtrl.text = 'INV-EDITED';
    await tester.ensureVisible(find.text('Update'));
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseDetailWidget), findsOneWidget);
    expect(find.text('INV-EDITED'), findsWidgets);
  });

  testWidgets('detail has an empty-items state', (tester) async {
    final c = await seedPurchase();
    await pumpPurchaseHost(tester, home: PurchasesScreen());
    c.purchaseList[0] = {...c.purchaseList.first, 'purchase_items': []};
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    expect(find.text('No items in this purchase'), findsOneWidget);
  });

  testWidgets('detail status colors survive Khmer labels', (tester) async {
    final c = await seedPurchase();
    c.purchaseList[0] = {...c.purchaseList.first, 'payment_status': 'paid'};
    await pumpPurchaseHost(
      tester,
      home: PurchasesScreen(),
      locale: const Locale('km', 'KH'),
    );
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    final chip = tester.widget<Text>(find.text('បានបង់').first);
    expect(chip.style?.color, AppTheme.light().colorScheme.primary);
  });

  testWidgets('detail survives Khmer and large text on a narrow screen', (
    tester,
  ) async {
    final c = await seedPurchase();
    await pumpPurchaseHost(
      tester,
      home: PurchasesScreen(),
      size: const Size(360, 720),
      locale: const Locale('km', 'KH'),
      textScale: 1.3,
    );
    c.gotoPurchaseDetail(c.purchaseList.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
