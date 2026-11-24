import 'package:frontend/constants/enum.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class NavigationSaleController extends SaleController {
  NavigationSaleController(SaleTestSaleService sales)
    : super(service: sales, productService: SaleTestProductService());
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  testWidgets('retry from the empty product screen submits the saved request', (
    tester,
  ) async {
    final sales = SaleTestSaleService();
    final ctr = Get.put<SaleController>(NavigationSaleController(sales));
    final local = locator<IStorageService>();
    await local.writeStorage(StorageKey.pendingCheckouts, {
      '${sales.baseUrl}|5': {
        'request': {
          'checkout_id': 'a' * 32,
          'customer_id': 1,
          'payment_type_id': 1,
          'expected_total': '5.00',
          'sale_items': [
            {'product_id': 1, 'warehouse_id': 1, 'qty': 1},
          ],
        },
      },
    });
    addTearDown(() => local.writeStorage(StorageKey.pendingCheckouts, {}));
    ctr.restorePendingCheckout();
    await pumpSalesPage(
      tester,
      SaleScreen(),
      getPages: [
        GetPage(name: '/current-sale', page: () => CurrentSaleWidget()),
        GetPage(
          name: '/payment-success',
          page: () => const PaymentSuccessWidget(),
        ),
      ],
    );
    await tester.tap(find.text('Retry checkout'));
    await tester.pumpAndSettle();
    expect(sales.requests, hasLength(1));
    expect(Get.currentRoute, '/payment-success');
  });
  testWidgets('sell through current cart confirmation receipt and back', (
    tester,
  ) async {
    final sales = SaleTestSaleService();
    final payments = SaleTestPaymentService();
    final ctr = Get.put<SaleController>(
      NavigationSaleController(sales),
      permanent: true,
    );
    ctr.categories.add({
      'name': 'Drinks',
      'products': [saleProductJson(1, 'Water')],
    });
    ctr.customers.add({'id': 1, 'name': 'Dara'});
    ctr.selectedCustomer.value = ctr.customers.first;
    ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
    ctr.selectedPaymentType.value = ctr.paymentTypes.first;
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        translations: AppTranslation(),
        locale: const Locale('en', 'US'),
        initialRoute: '/home',
        builder: (context, child) =>
            DesktopAppShell(route: Get.currentRoute, child: child!),
        getPages: [
          GetPage(
            name: '/home',
            page: () => Scaffold(
              body: TextButton(
                onPressed: () => Get.toNamed('/sale'),
                child: const Text('Quick sale'),
              ),
            ),
          ),
          GetPage(name: '/sale', page: () => SaleScreen()),
          GetPage(name: '/current-sale', page: () => CurrentSaleWidget()),
          GetPage(
            name: '/payment-success',
            page: () => const PaymentSuccessWidget(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick sale'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Water'));
    await tester.pump();
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/current-sale');
    expect(find.byType(CustomAppBar), findsOneWidget);
    await tester.ensureVisible(find.text('Back to products'));
    await tester.tap(find.text('Back to products'));
    await tester.pumpAndSettle();
    expect(ctr.totalItems, 1);
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Payment'));
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/payment-success');
    expect(sales.requests, hasLength(1));
    expect(payments.createCalls, isEmpty);
    await tester.ensureVisible(find.text('Back to Sale'));
    await tester.tap(find.text('Back to Sale'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/sale');
    expect(ctr.totalItems, 0);
    expect(tester.takeException(), isNull);
  });
}
