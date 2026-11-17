import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/screen/payment/widget/payment_form_widget.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';
import 'package:get/get.dart';

import 'customer_test_support.dart' show setUpCustomerTests;
import 'payment_crud_test.dart' as fixtures;
import 'sale_test_support.dart';

class _IntegrationSales extends SaleTestSaleService {
  int reads = 0;
  bool requireInvoice = false;

  @override
  Future<dynamic> getSales() async {
    reads++;
    return sales;
  }

  @override
  Future<dynamic> createSale(Map<String, dynamic> data) async {
    if (requireInvoice && !data.containsKey('invoice_no')) {
      createCalls.add(Map.of(data));
      throw Exception('invoice_no Field required');
    }
    return super.createSale(data);
  }
}

class _QuietSaleController extends SaleController {
  _QuietSaleController(
    SaleTestSaleService sales,
    SaleTestPaymentService payments,
  ) : super(service: sales, salePaymentService: payments);
  @override
  // ignore: must_call_super
  void onInit() {}
}

Future<void> _pumpWriteShell(
  WidgetTester tester,
  Widget page,
  String route,
) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en', 'US'),
      initialRoute: route,
      builder: (context, child) => DesktopAppShell(route: route, child: child!),
      getPages: [
        GetPage(name: route, page: () => page),
        GetPage(
          name: '/home',
          page: () => const Scaffold(body: Text('Other destination')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDetail(
  WidgetTester tester, {
  Size size = const Size(1200, 900),
  double scale = 1,
}) async {
  Get.put(SaleListController(service: _IntegrationSales()));
  await pumpSalesPage(tester, const Scaffold(), size: size, textScale: scale);
  Get.to(() => const SaleListDetailWidget(), arguments: saleJson(1));
  await tester.pumpAndSettle();
}

Finder _section(String title) => find.byWidgetPredicate(
  (widget) => widget is HomeSectionCard && widget.title == title,
);

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is AppFormField && widget.label == label,
);

void main() {
  setUp(() {
    setUpCustomerTests();
    SaleListController.invalidateCache();
  });
  tearDown(() {
    Get.reset();
    SaleListController.invalidateCache();
  });

  testWidgets('desktop sidebar cannot abandon a held checkout', (tester) async {
    final held = Completer<dynamic>();
    final ctr = Get.put<SaleController>(
      _QuietSaleController(
        _IntegrationSales(),
        SaleTestPaymentService()..heldWrite = held,
      ),
    );
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.customers.add({'id': 1, 'name': 'Dara'});
    ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
    ctr.selectedCustomer.value = ctr.customers.first;
    ctr.selectedPaymentType.value = ctr.paymentTypes.first;
    await _pumpWriteShell(tester, CurrentSaleWidget(), '/current-sale');
    await tester.tap(find.widgetWithText(FilledButton, 'Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Manage'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    final routeDuringWrite = Get.currentRoute;
    held.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(routeDuringWrite, '/current-sale');
    expect(find.byType(CurrentSaleWidget), findsOneWidget);
    expect(ctr.totalItems, 1);
    expect(ctr.checkoutError.value, isNotEmpty);
    expect(
      tester
          .widget<NavigationRail>(find.byType(NavigationRail))
          .onDestinationSelected,
      isNotNull,
    );
  });

  testWidgets('desktop sidebar cannot abandon a held payment save', (
    tester,
  ) async {
    final gate = Completer<void>();
    final service = fixtures.FakeSalePaymentService()..createGate = gate;
    final ctr = Get.put(
      PaymentController(
        service: service,
        saleService: fixtures.FakeSaleService(sales: [fixtures.saleFixture()]),
      ),
    );
    await _pumpWriteShell(tester, PaymentScreen(), '/sale-payment');
    await tester.tap(find.widgetWithText(FilledButton, 'Add Payment'));
    await tester.pumpAndSettle();
    await fixtures.fillValidPayment(ctr);
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Manage'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    final routeDuringWrite = Get.currentRoute;
    final formDuringWrite = find
        .byType(PaymentFormWidget)
        .evaluate()
        .isNotEmpty;
    service.failure = Exception('offline');
    gate.complete();
    await tester.pumpAndSettle();
    expect(routeDuringWrite, '/sale-payment');
    expect(formDuringWrite, isTrue);
    expect(find.byType(PaymentFormWidget), findsOneWidget);
    expect(ctr.amountCtrl.text, '25.5');
    expect(ctr.formError.value, isNotEmpty);
  });

  test(
    'sales and payment form labels and validation have both translations',
    () {
      for (final key in [
        'Add Payment',
        'Edit Payment',
        'Search Payment',
        'Payment Method',
        'Reference No',
        'Select Sale',
        'No sale with outstanding balance',
        'Please select a sale',
        'Amount cannot exceed sale due',
        'Payment method is required',
        'Reference is required',
        'Sale Status',
        'Items',
        'Invoice',
        'Tax',
        'Discount',
        'Subtotal',
        'Paid',
        'Due',
        'Export Error',
        'Sold out',
        'Transaction ID',
        'Field',
        'Value',
        'Please correct the highlighted fields.',
      ]) {
        expect(enUS.containsKey(key), isTrue, reason: 'English $key');
        expect(kmKH.containsKey(key), isTrue, reason: 'Khmer $key');
      }
    },
  );

  for (final feature in ['products', 'history', 'payments']) {
    testWidgets(
      '$feature loading and initial failure do not claim empty inventory',
      (tester) async {
        late Widget page;
        late RxBool loading;
        late RxString error;
        if (feature == 'products') {
          final ctr = Get.put(
            SaleController(
              service: _IntegrationSales(),
              productService: SaleTestProductService(),
              customerService: SaleTestCustomerService(),
              currencyService: SaleTestCurrencyService(),
              paymentTypeService: SaleTestPaymentTypeService(),
              salePaymentService: SaleTestPaymentService(),
            ),
          );
          page = SaleScreen();
          loading = ctr.isLoading;
          error = ctr.productLoadError;
        } else if (feature == 'history') {
          final ctr = Get.put(SaleListController(service: _IntegrationSales()));
          page = SaleListScreen();
          loading = ctr.isLoading;
          error = ctr.loadError;
        } else {
          final ctr = Get.put(
            PaymentController(
              service: fixtures.FakeSalePaymentService(),
              saleService: _IntegrationSales(),
            ),
          );
          page = PaymentScreen();
          loading = ctr.isLoading;
          error = ctr.loadError;
        }
        await pumpSalesPage(tester, page);
        expect(find.byTooltip('Back'), findsOneWidget);
        loading.value = true;
        await tester.pump();
        expect(find.byType(AppEmptyState), findsNothing);
        loading.value = false;
        error.value = 'Unable to load sales. Please try again.';
        await tester.pump();
        expect(find.byType(AppEmptyState), findsNothing);
        expect(
          find.text('Unable to load sales. Please try again.'),
          findsOneWidget,
        );
      },
    );
  }

  for (final fallback in [false, true]) {
    testWidgets(
      'checkout invalidates history before payment and cleanup fallback=$fallback',
      (tester) async {
        final sales = _IntegrationSales()..requireInvoice = fallback;
        await SaleListController(service: sales).onGetSaleList();
        final held = Completer<dynamic>();
        final payments = SaleTestPaymentService()..heldWrite = held;
        final ctr = SaleController(
          service: sales,
          salePaymentService: payments,
        );
        ctr.addProduct(saleProductJson(1, 'Water'));
        ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
        ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
        await pumpSalesPage(tester, const Scaffold());
        final checkout = ctr.onPayment();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm'));
        await tester.pump();
        final afterCreate = SaleListController(service: sales)..onInit();
        await tester.pump();
        expect(
          sales.reads,
          2,
          reason:
              'A successful create invalidates cached history before payment completes',
        );
        held.completeError(Exception('offline'));
        await tester.pumpAndSettle();
        await checkout;
        final afterCleanup = SaleListController(service: sales)..onInit();
        await tester.pump();
        expect(sales.deleteCalls, [1]);
        expect(
          sales.reads,
          3,
          reason:
              'Successful compensating deletion invalidates history warmed during payment',
        );
        expect(ctr.totalItems, 1);
        afterCreate.onClose();
        afterCleanup.onClose();
        ctr.onClose();
      },
    );
  }

  testWidgets('successful checkout invalidates history loaded during payment', (
    tester,
  ) async {
    final sales = _IntegrationSales();
    await SaleListController(service: sales).onGetSaleList();
    final held = Completer<dynamic>();
    final ctr = SaleController(
      service: sales,
      salePaymentService: SaleTestPaymentService()..heldWrite = held,
    );
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(),
        getPages: [
          GetPage(
            name: '/payment-success',
            page: () => const Scaffold(body: Text('Receipt')),
          ),
        ],
      ),
    );
    final checkout = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    final during = SaleListController(service: sales)..onInit();
    await tester.pump();
    expect(sales.reads, 2);
    held.complete(salePaymentJson(1));
    await tester.pumpAndSettle();
    await checkout;
    final after = SaleListController(service: sales)..onInit();
    await tester.pump();
    expect(sales.reads, 3);
    expect(find.text('Receipt'), findsOneWidget);
    during.onClose();
    after.onClose();
    ctr.onClose();
  });

  for (final size in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets(
      'history detail new-sale and payment-save routes preserve separate queries $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final sales = _IntegrationSales()..sales = [saleJson(1)];
        final history = Get.put(
          SaleListController(service: sales),
          permanent: true,
        );
        final selling = Get.put(
          SaleController(
            service: _IntegrationSales(),
            productService: SaleTestProductService(),
            customerService: SaleTestCustomerService(),
            currencyService: SaleTestCurrencyService(),
            paymentTypeService: SaleTestPaymentTypeService(),
            salePaymentService: SaleTestPaymentService(),
          ),
          permanent: true,
        );
        final paymentService = fixtures.FakeSalePaymentService(
          payments: [fixtures.paymentFixture()],
        );
        final payments = Get.put(
          PaymentController(
            service: paymentService,
            saleService: fixtures.FakeSaleService(
              sales: [fixtures.saleFixture()],
            ),
          ),
          permanent: true,
        );
        history.searchCtr.keyword.value = 'SALE-1';
        selling.searchCtr.keyword.value = 'Water';
        payments.searchCtr.keyword.value = 'REF-1';
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light(),
            initialRoute: '/sale-list',
            builder: (context, child) =>
                DesktopAppShell(route: '/sale-list', child: child!),
            getPages: [
              GetPage(name: '/sale-list', page: () => SaleListScreen()),
              GetPage(
                name: '/sale-list-detail',
                page: () => const SaleListDetailWidget(),
              ),
              GetPage(name: '/sale', page: () => SaleScreen()),
              GetPage(name: '/sale-payment', page: () => PaymentScreen()),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'SALE-1',
          ),
        );
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/sale-list-detail');
        expect((Get.arguments as Map)['id'], 1);
        await tester.tap(find.widgetWithText(FilledButton, 'New Sale'));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/sale');
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Water',
        );
        Get.offNamed('/sale-payment');
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Add Payment'));
        await tester.pumpAndSettle();
        await fixtures.fillValidPayment(payments);
        await tester.pump();
        final save = find.widgetWithText(FilledButton, 'Save');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(paymentService.createCalls, hasLength(1));
        expect(find.byType(PaymentFormWidget), findsNothing);
        expect(history.searchCtr.keyword.value, 'SALE-1');
        expect(selling.searchCtr.keyword.value, 'Water');
        expect(payments.searchCtr.keyword.value, 'REF-1');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('wide detail pairs invoice and payment; large text stacks them', (
    tester,
  ) async {
    await _openDetail(tester);
    final invoice = tester.getTopLeft(_section('Invoice'));
    final payment = tester.getTopLeft(_section('Payment'));
    expect(payment.dx, greaterThan(invoice.dx));
    expect(payment.dy, closeTo(invoice.dy, 1));
    expect(find.text('Sale Status'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'detail displays failed deletion without losing the selected sale',
    (tester) async {
      await _openDetail(tester);
      Get.find<SaleListController>().loadError.value =
          'Unable to delete sale. Please try again.';
      await tester.pump();
      expect(
        find.text('Unable to delete sale. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('SALE-1'), findsOneWidget);
    },
  );

  testWidgets(
    'wide payment fields pair and blank save focuses the first error',
    (tester) async {
      final ctr = PaymentController(
        service: fixtures.FakeSalePaymentService(),
        saleService: fixtures.FakeSaleService(),
      );
      Get.put(ctr);
      ctr.saleList.add(fixtures.saleFixture());
      ctr.selectedSaleId.value = 3;
      await pumpSalesPage(
        tester,
        Scaffold(body: PaymentFormWidget()),
        size: const Size(1000, 800),
      );
      final amount = tester.getTopLeft(_field('Amount'));
      final method = tester.getTopLeft(_field('Payment Method'));
      expect(method.dx, greaterThan(amount.dx));
      expect(method.dy, closeTo(amount.dy, 1));
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final input = tester.widget<TextField>(
        find.descendant(of: _field('Amount'), matching: find.byType(TextField)),
      );
      expect(input.focusNode?.hasFocus, isTrue);
      expect(
        find.text('Please correct the highlighted fields.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    for (final khmer in [false, true]) {
      testWidgets('management detail and form reflow dark=$dark khmer=$khmer', (
        tester,
      ) async {
        final locale = khmer
            ? const Locale('km', 'KH')
            : const Locale('en', 'US');
        Get.put(SaleListController(service: _IntegrationSales()));
        await pumpSalesPage(
          tester,
          const Scaffold(),
          size: const Size(1440, 600),
          textScale: 2,
          dark: dark,
          locale: locale,
          desktopShell: true,
        );
        Get.to(
          () => const SaleListDetailWidget(),
          arguments: {
            ...saleJson(1),
            'invoice_no': 'វិក្កយបត្រលក់ដែលមានអត្ថបទវែងជាច្រើនសម្រាប់ពិនិត្យ',
          },
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final invoice = tester.getTopLeft(_section('Invoice'.tr));
        final payment = tester.getTopLeft(_section('Payment'.tr));
        expect(payment.dy, greaterThan(invoice.dy));
        Get.back();
        await tester.pumpAndSettle();
        final ctr = Get.put(
          PaymentController(
            service: fixtures.FakeSalePaymentService(),
            saleService: fixtures.FakeSaleService(),
          ),
        );
        ctr.saleList.add(fixtures.saleFixture());
        ctr.selectedSaleId.value = 3;
        await pumpSalesPage(
          tester,
          Scaffold(body: PaymentFormWidget()),
          size: const Size(844, 500),
          textScale: 2,
          dark: dark,
          locale: locale,
          desktopShell: true,
        );
        final amount = tester.getTopLeft(_field('Amount'));
        final method = tester.getTopLeft(_field('Payment Method'));
        expect(method.dy, greaterThan(amount.dy));
        await tester.ensureVisible(find.text('Save'.tr));
        await tester.tap(find.text('Save'.tr));
        await tester.pumpAndSettle();
        expect(
          find.text('Please correct the highlighted fields.'.tr),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
