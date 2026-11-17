import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'sales_navigation_test.dart' show NavigationSaleController;
import 'customer_test_support.dart' show setUpCustomerTests;

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  for (final route in [
    '/sale',
    '/current-sale',
    '/sale-payment',
    '/payment-success',
    '/sale-list',
    '/sale-list-detail',
  ]) {
    testWidgets('mobile app bar returns safely and retains draft $route', (
      tester,
    ) async {
      final sales = SaleTestSaleService();
      final payments = SaleTestPaymentService();
      final ctr = Get.put<SaleController>(
        NavigationSaleController(sales, payments),
        permanent: true,
      );
      ctr.addProduct(saleProductJson(1, 'Water'));
      SaleListController.invalidateCache();
      Get.put(SaleListController(service: sales), permanent: true);
      Get.put(
        PaymentController(service: payments, saleService: sales),
        permanent: true,
      );
      final Widget page = switch (route) {
        '/sale' => SaleScreen(),
        '/current-sale' => CurrentSaleWidget(),
        '/sale-payment' => PaymentScreen(),
        '/payment-success' => const PaymentSuccessWidget(),
        '/sale-list' => SaleListScreen(),
        _ => const SaleListDetailWidget(),
      };
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(),
          translations: AppTranslation(),
          locale: const Locale('en', 'US'),
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const Scaffold(body: Text('Home boundary')),
            ),
            GetPage(name: '/sale', page: () => SaleScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.to(() => page);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(ctr.totalItems, 1);
      if (route == '/payment-success') {
        expect(Get.currentRoute, '/sale');
      } else {
        expect(find.text('Home boundary'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(1440, 900),
  ]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        for (final route in [
          '/sale',
          '/current-sale',
          '/sale-payment',
          '/payment-success',
          '/sale-list',
          '/sale-list-detail',
        ]) {
          testWidgets(
            'six sales routes follow supplier navigation placement $route $size dark=$dark km=$khmer',
            (tester) async {
              final sales = SaleTestSaleService();
              final payments = SaleTestPaymentService();
              Get.put<SaleController>(
                NavigationSaleController(sales, payments),
              );
              SaleListController.invalidateCache();
              Get.put(SaleListController(service: sales));
              Get.put(PaymentController(service: payments, saleService: sales));
              final Widget page = switch (route) {
                '/sale' => SaleScreen(),
                '/current-sale' => CurrentSaleWidget(),
                '/sale-payment' => PaymentScreen(),
                '/payment-success' => const PaymentSuccessWidget(),
                '/sale-list' => SaleListScreen(),
                _ => const SaleListDetailWidget(),
              };
              final desktop = size.width == 1440;
              await pumpSalesPage(
                tester,
                page,
                size: size,
                dark: dark,
                locale: khmer
                    ? const Locale('km', 'KH')
                    : const Locale('en', 'US'),
                textScale: 2,
                desktopShell: desktop,
                route: route,
              );
              expect(
                find.byType(CustomAppBar),
                desktop ? findsNothing : findsOneWidget,
              );
              expect(find.byType(AppPage), findsOneWidget);
              expect(find.byType(AppPageHeader), findsOneWidget);
              final header = tester.widget<AppPageHeader>(
                find.byType(AppPageHeader),
              );
              if (!desktop) {
                expect(header.leading, isNull);
              } else if (![
                '/current-sale',
                '/payment-success',
              ].contains(route)) {
                expect(header.leading, isA<IconButton>());
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
