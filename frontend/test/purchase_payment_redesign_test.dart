import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/screen/purchase_payment/purchase_payment_screen.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_card_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_detail_widget.dart';
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

  testWidgets('list adapts cards and table to usable width', (tester) async {
    await seedPurchasePaymentController();
    await pumpPurchasePaymentHost(
      tester,
      home: PurchasePaymentScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(PurchasePaymentCardWidget), findsNWidgets(2));
    expect(find.byType(PurchasePaymentTableWidget), findsNothing);
    await pumpPurchasePaymentHost(
      tester,
      home: PurchasePaymentScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(PurchasePaymentTableWidget), findsOneWidget);
  });

  testWidgets('loading, error, empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seedPurchasePaymentController();
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    c.loadError.value = 'Unable to load purchase payments. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchPayments('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching purchase payments'), findsOneWidget);
    c.purchasePaymentList.clear();
    c.searchPayments('');
    await tester.pumpAndSettle();
    expect(find.text('No purchase payments yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-purchase-payment')), findsOneWidget);
  });

  testWidgets('retry keeps the active search query', (tester) async {
    final c = await seedPurchasePaymentController();
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    final search = Get.find<SearchController>();
    search.keyword.value = 'pp-2';
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.searchPaymentList, hasLength(1));
    await c.onRefresh();
    await tester.pumpAndSettle();
    expect(c.searchPaymentList, hasLength(1));
  });

  testWidgets('long Khmer content reflows in both themes', (tester) async {
    final c = await seedPurchasePaymentController();
    c.purchasePaymentList[0] = {
      ...c.purchasePaymentList.first,
      'payment_no': 'ទូទាត់ ' * 12,
    };
    c.searchPayments('');
    for (final dark in [false, true]) {
      await pumpPurchasePaymentHost(
        tester,
        home: PurchasePaymentScreen(),
        size: const Size(360, 720),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('detail renders placeholders for missing fields', (tester) async {
    await seedPurchasePaymentController();
    await pumpPurchasePaymentHost(
      tester,
      home: const PurchasePaymentDetailWidget(
        payment: {'id': 999, 'payment_no': 'PP-X'},
      ),
    );
    expect(find.text('PP-X'), findsWidgets);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail shows real values', (tester) async {
    final c = await seedPurchasePaymentController();
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    await tester.tap(find.byType(PurchasePaymentCardWidget).first);
    await tester.pumpAndSettle();
    expect(find.byType(PurchasePaymentDetailWidget), findsOneWidget);
    expect(find.text('PP-1'), findsWidgets);
    expect(find.text('Supplier A'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('\$40.00'), findsWidgets);
    expect(c.purchasePaymentList, hasLength(2));
  });

  testWidgets('delete from detail closes it and refreshes the list', (
    tester,
  ) async {
    final s = FakePurchasePaymentService();
    final c = await seedPurchasePaymentController(service: s);
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    await tester.tap(find.byType(PurchasePaymentCardWidget).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Do you want to delete this purchase payment?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 1);
    expect(find.byType(PurchasePaymentDetailWidget), findsNothing);
    expect(find.byType(PurchasePaymentScreen), findsOneWidget);
    expect(c.purchasePaymentList, hasLength(1));
  });

  testWidgets('failed delete keeps the detail open', (tester) async {
    final s = FakePurchasePaymentService()..failWrite = true;
    final c = await seedPurchasePaymentController(service: s);
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    await tester.tap(find.byType(PurchasePaymentCardWidget).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchasePaymentDetailWidget), findsOneWidget);
    expect(c.purchasePaymentList, hasLength(2));
    expect(
      find.text('Unable to delete purchase payment. Please try again.'),
      findsWidgets,
    );
  });

  testWidgets('edit from detail refreshes the displayed amount', (
    tester,
  ) async {
    final s = FakePurchasePaymentService();
    await seedPurchasePaymentController(service: s);
    await pumpPurchasePaymentHost(tester, home: PurchasePaymentScreen());
    await tester.tap(find.byType(PurchasePaymentCardWidget).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Edit'));
    await tester.pumpAndSettle();
    Get.find<PurchasePaymentController>().amountCtrl.text = '45';
    await tester.ensureVisible(find.text('Update'));
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchasePaymentDetailWidget), findsOneWidget);
    expect(find.text('\$45.00'), findsWidgets);
  });
}
