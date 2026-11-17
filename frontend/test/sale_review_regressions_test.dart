import 'package:flutter/services.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/payment/sale_with_payment/widget/payment_method_card_widget.dart';
import 'package:frontend/services/export_service.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class ReviewSaleController extends SaleController {
  ReviewSaleController(
    SaleTestSaleService sales, {
    SaleTestPaymentService? payments,
  }) : super(
         service: sales,
         salePaymentService: payments,
         productService: SaleTestProductService(),
       );
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  testWidgets('actual held checkout freezes draft back and selectors', (
    tester,
  ) async {
    final sales = SaleTestSaleService()..heldCreate = Completer<dynamic>();
    final payments = SaleTestPaymentService()..heldWrite = Completer<dynamic>();
    final ctr = Get.put<SaleController>(
      ReviewSaleController(sales, payments: payments),
    );
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
    ctr.selectedPaymentType.value = ctr.paymentTypes.first;
    await pumpSalesPage(tester, const Scaffold());
    Get.to(() => CurrentSaleWidget());
    await tester.pumpAndSettle();
    final route = Get.currentRoute;
    final action = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(sales.createCalls, hasLength(1));
    expect(payments.createCalls, isEmpty);
    ctr.addProduct(saleProductJson(2, 'Bread'));
    ctr.changeQuantity(1, -1);
    ctr.selectCustomer({'id': 2});
    ctr.selectPaymentType({'id': 2});
    expect(ctr.totalItems, 1);
    expect(ctr.selectedCustomer.value?['id'], 1);
    expect(ctr.selectedPaymentType.value?['id'], 1);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, route);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, route);
    await ctr.onPayment();
    expect(sales.createCalls, hasLength(1));
    sales.heldCreate!.complete(saleJson(1));
    await tester.pumpAndSettle();
    expect(payments.createCalls, hasLength(1));
    expect(ctr.checkoutBusy, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    payments.heldWrite!.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    await action;
    expect(ctr.totalItems, 1);
    expect(ctr.checkoutBusy, isFalse);
    expect(sales.deleteCalls, [1]);
  });
  for (final missing in ['customer', 'method', 'cart', 'user']) {
    testWidgets('missing $missing prevents checkout writes', (tester) async {
      final sales = SaleTestSaleService();
      final payments = SaleTestPaymentService();
      final ctr = ReviewSaleController(sales, payments: payments);
      ctr.addProduct(saleProductJson(1, 'Water'));
      ctr.selectedCustomer.value = {'id': 1};
      ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
      final stored = locator<IStorageService>().lastUserLoginRead;
      final user = stored['user'];
      if (missing == 'customer') ctr.selectedCustomer.value = null;
      if (missing == 'method') ctr.selectedPaymentType.value = null;
      if (missing == 'cart') ctr.cart.clear();
      if (missing == 'user') stored.remove('user');
      try {
        await pumpSalesPage(tester, const Scaffold());
        await ctr.onPayment();
        await tester.pumpAndSettle();
        expect(sales.createCalls, isEmpty);
        expect(payments.createCalls, isEmpty);
        expect(find.byType(AlertDialog), findsNothing);
      } finally {
        stored['user'] = user;
      }
    });
  }
  for (final invoiceRequired in [false, true]) {
    testWidgets(
      'invoice compatibility retries only missing invoice=$invoiceRequired',
      (tester) async {
        final sales = SaleTestSaleService()
          ..createError = Exception(
            invoiceRequired ? 'invoice_no Field required' : 'offline',
          );
        final payments = SaleTestPaymentService();
        final ctr = ReviewSaleController(sales, payments: payments);
        ctr.addProduct(saleProductJson(1, 'Water'));
        ctr.selectedCustomer.value = {'id': 1};
        ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
        await pumpSalesPage(tester, const Scaffold());
        final action = ctr.onPayment();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        await action;
        expect(sales.createCalls, hasLength(invoiceRequired ? 2 : 1));
        expect(sales.createCalls.first.containsKey('invoice_no'), isFalse);
        if (invoiceRequired) {
          expect(sales.createCalls.last['invoice_no'], startsWith('SALE-'));
        }
        expect(payments.createCalls, isEmpty);
        expect(ctr.totalItems, 1);
      },
    );
  }
  testWidgets('mounted method reload and keyboard quantity remain usable', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(
      ReviewSaleController(SaleTestSaleService()),
    );
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.paymentTypes.add({'id': 1, 'name': 'Old'});
    ctr.selectedPaymentType.value = ctr.paymentTypes.first;
    await pumpSalesPage(
      tester,
      CurrentSaleWidget(),
      size: const Size(390, 500),
    );
    ctr.paymentTypes.assignAll([
      {'id': 1, 'name': 'New'},
    ]);
    ctr.selectedPaymentType.value = ctr.paymentTypes.first;
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final decrease = find.byTooltip('Decrease quantity');
    await tester.ensureVisible(decrease);
    Focus.of(
      tester.element(
        find.descendant(of: decrease, matching: find.byType(Icon)),
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(ctr.totalItems, 0);
    expect(find.text('No products selected'), findsOneWidget);
  });
  testWidgets('compact product page has an in-app back control', (
    tester,
  ) async {
    Get.put<SaleController>(ReviewSaleController(SaleTestSaleService()));
    await pumpSalesPage(tester, SaleScreen());
    expect(find.byTooltip('Back'), findsOneWidget);
  });
  testWidgets('empty payment methods offer retry', (tester) async {
    var calls = 0;
    await pumpSalesPage(
      tester,
      Scaffold(
        body: PaymentMethodCardWidget(
          paymentTypes: const [],
          selectedPaymentType: null,
          onChanged: (_) {},
          onRetry: () => calls++,
        ),
      ),
    );
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(calls, 1);
  });
  for (final invalid in [
    'invalid',
    [null],
    [
      {'name': 'missing id'},
    ],
  ]) {
    test(
      'malformed nested products preserve prior categories $invalid',
      () async {
        final sales = SaleTestSaleService()
          ..categories = [
            {
              'name': 'Good',
              'products': [saleProductJson(1, 'Water')],
            },
          ];
        final ctr = ReviewSaleController(sales);
        await ctr.loadProductCategories();
        sales.categories = [
          {'name': 'Bad', 'products': invalid},
        ];
        await ctr.loadProductCategories();
        expect(ctr.productLoadError.value, isNotEmpty);
        expect(ctr.categories.single['name'], 'Good');
      },
    );
  }
  test('Khmer receipt PDF embeds supported glyphs', () async {
    final messages = <String>[];
    final bytes = await runZoned(
      () => ExportService.generatePdf(
        title: 'បង្កាន់ដៃ',
        headers: ['អតិថិជន', 'តម្លៃ'],
        rows: [
          ['Dara', '12.50'],
        ],
      ),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          messages.add(line);
        },
      ),
    );
    expect(bytes.take(4), [37, 80, 68, 70]);
    expect(
      messages.where(
        (line) =>
            line.contains('Unable to find a font') ||
            line.contains('has no Unicode support'),
      ),
      isEmpty,
    );
  });
}
