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
import 'package:frontend/ui/app_section_card.dart';
import 'payment_success_widget_test.dart' as receipt_fixtures;
import 'dart:async';

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  for (final detail in [false, true]) {
    testWidgets(
      'long ${detail ? 'invoice' : 'transaction'} in compact Khmer at 2x',
      (tester) async {
        final longValue = List.filled(12, 'វិក្កយបត្រលក់វែង').join(' ');
        final fake = receipt_fixtures.FakeReportExportController();
        if (detail) {
          Get.put(SaleListController(service: SaleTestSaleService()));
        }
        await pumpSalesPage(
          tester,
          const Scaffold(),
          size: const Size(844, 390),
          locale: const Locale('km', 'KH'),
          textScale: 2,
        );
        Get.to(
          () => detail
              ? const SaleListDetailWidget()
              : PaymentSuccessWidget(exportController: fake),
          arguments: detail
              ? {...saleJson(1), 'invoice_no': longValue}
              : {...receipt_fixtures.receipt, 'transaction_id': longValue},
        );
        await tester.pumpAndSettle();
        expect(find.text(longValue), findsOneWidget);
        final controls = detail
            ? [
                find.byTooltip('Back'.tr),
                find.text('New Sale'.tr),
                find.text('Delete'.tr),
              ]
            : [find.text('Back to Sale'.tr), find.text('Export Receipt'.tr)];
        for (final control in controls) {
          await tester.ensureVisible(control);
          await tester.pumpAndSettle();
          expect(control.hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('receipt uses shared surface without changing export rows', (
    tester,
  ) async {
    final fake = receipt_fixtures.FakeReportExportController()
      ..held = Completer<String?>();
    final data = {
      ...receipt_fixtures.receipt,
      'payment_date': '2026-11-08T11:30:00',
    };
    await pumpSalesPage(tester, const Scaffold(), size: const Size(1440, 900));
    Get.to(() => PaymentSuccessWidget(exportController: fake), arguments: data);
    await tester.pumpAndSettle();
    expect(find.byType(AppSectionCard), findsOneWidget);
    const rows = [
      ['Customer', 'Alice'],
      ['Payment Method', 'Cash'],
      ['Date', '08-11-2026 11:30'],
      ['Transaction ID', 'SALE-1'],
      ['Subtotal', r'$8.00'],
      ['Total', r'$10.00'],
    ];
    for (final row in rows) {
      for (final text in row) {
        expect(find.text(text), findsOneWidget);
      }
    }
    await tester.ensureVisible(find.text('Export Receipt'));
    await tester.tap(find.text('Export Receipt'));
    await tester.pump();
    await tester.tap(find.text('Exporting...'));
    expect(fake.calls, hasLength(1));
    expect(fake.calls.single.rows, rows);
    fake.held!.completeError(Exception('disk full'));
    await tester.pumpAndSettle();
    expect(find.text('SALE-1'), findsOneWidget);
    expect(find.text(r'$10.00'), findsOneWidget);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
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
