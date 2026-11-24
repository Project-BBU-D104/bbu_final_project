import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_card_widget.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/app_cached_image.dart';
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
  for (final size in [const Size(375, 667), const Size(844, 390)]) {
    testWidgets('product search remains usable with the keyboard at $size', (
      tester,
    ) async {
      final cart = seedCart();
      final landscape = size.width > size.height;
      final padding = FakeViewPadding(
        left: landscape ? 28 : 0,
        top: landscape ? 24 : 0,
        right: landscape ? 28 : 0,
        bottom: 24,
      );
      tester.view.viewPadding = padding;
      tester.view.padding = padding;
      addTearDown(tester.view.resetViewPadding);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewInsets);
      await pumpSalesPage(
        tester,
        SaleScreen(),
        size: size,
        locale: landscape ? const Locale('km', 'KH') : const Locale('en', 'US'),
        dark: landscape,
        textScale: landscape ? 2 : 1,
        desktopShell: true,
      );
      final search = find.byType(TextField);
      final scan = find.byTooltip('Scan Barcode'.tr);
      final footer = find.descendant(
        of: find.byType(PaymentFooterWidget),
        matching: find.byType(FilledButton),
      );
      await expectReachable(tester, scan);
      await tester.tap(search);
      const keyboardHeight = 260.0;
      tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
      tester.view.padding = FakeViewPadding(
        left: padding.left,
        top: padding.top,
        right: padding.right,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(search).bottom,
        lessThanOrEqualTo(size.height - keyboardHeight),
      );
      expect(search.hitTestable(), findsOneWidget);
      expect(search.hitTestable(at: const Alignment(0, -.8)), findsOneWidget);
      expect(search.hitTestable(at: const Alignment(0, .8)), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      await tester.enterText(search, 'Water');
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.resetViewInsets();
      tester.view.padding = padding;
      await tester.pumpAndSettle();
      expect(cart.searchCtr.keyword.value, 'Water');
      expect(cart.totalItems, 1);
      final lastProduct = find.text('Water 8');
      await expectReachable(tester, lastProduct);
      expect(footer.hitTestable(), findsOneWidget);
      final bounds = tester.getRect(footer);
      expect(bounds.height, greaterThanOrEqualTo(AppTokens.controlHeight));
      expect(bounds.left, greaterThanOrEqualTo(padding.left));
      expect(bounds.right, lessThanOrEqualTo(size.width - padding.right));
      expect(bounds.bottom, lessThanOrEqualTo(size.height - padding.bottom));
      expect(tester.getRect(lastProduct).bottom, lessThanOrEqualTo(bounds.top));
      expect(tester.takeException(), isNull);
    });
  }
  for (final size in [const Size(375, 667), const Size(844, 390)]) {
    testWidgets('phone product thumbnails leave room for details at $size', (
      tester,
    ) async {
      seedCart(productName: 'Water');
      await pumpSalesPage(tester, SaleScreen(), size: size, desktopShell: true);
      final firstThumbnail = find.byType(AppCachedImage).first;
      expect(tester.getSize(firstThumbnail).height, lessThanOrEqualTo(80));
      expect(find.text('Water').hitTestable(), findsOneWidget);
    });
  }
  for (final (size, dark, locale, scale) in [
    (const Size(375, 667), false, const Locale('en', 'US'), 1.0),
    (const Size(844, 390), true, const Locale('km', 'KH'), 2.0),
    (const Size(320, 568), false, const Locale('km', 'KH'), 2.0),
  ]) {
    testWidgets('populated cart actions remain reachable at $size', (
      tester,
    ) async {
      final cart = seedCart(productName: size.width == 375 ? 'Water' : null);
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: size,
        dark: dark,
        locale: locale,
        textScale: scale,
        desktopShell: true,
        route: '/current-sale',
      );
      final increase = find.byTooltip('Increase quantity'.tr);
      await expectReachable(tester, increase);
      await tester.tap(increase);
      await tester.pumpAndSettle();
      expect(cart.totalItems, 2);
      await expectReachable(tester, find.text('Back to products'.tr));
      final payment = find.widgetWithText(FilledButton, 'Payment'.tr);
      await expectReachable(tester, payment);
      expect(tester.widget<FilledButton>(payment).onPressed, isNotNull);
      expect(
        tester.getSize(find.byType(CurrentSaleItemWidget)).width,
        tester.getSize(find.byType(SummaryOrderWidget)).width,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'recorded payments and form actions remain reachable at $size',
      (tester) async {
        final sales = SaleTestSaleService()..sales = [saleJson(1)];
        final payments = SaleTestPaymentService()
          ..payments = [salePaymentJson(1)];
        final controller = Get.put(
          PaymentController(service: payments, saleService: sales),
        );
        final landscape = size.width > size.height;
        if (landscape) {
          tester.view.padding = const FakeViewPadding(top: 24);
          tester.view.viewPadding = const FakeViewPadding(top: 24);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetViewPadding);
        }
        addTearDown(tester.view.resetViewInsets);
        await pumpSalesPage(
          tester,
          PaymentScreen(),
          size: size,
          dark: dark,
          locale: locale,
          textScale: scale,
          desktopShell: true,
          route: '/sale-payment',
        );
        await tester.pumpAndSettle();
        for (final editing in [false, true]) {
          if (editing) {
            await expectReachable(tester, find.text('REF-1'));
            await expectReachable(tester, find.byTooltip('Delete'.tr));
          }
          final open = editing
              ? find.byTooltip('Edit'.tr)
              : find.text('Add Payment'.tr);
          await expectReachable(tester, open);
          await tester.tap(open);
          await tester.pumpAndSettle();
          final reference = find.byWidgetPredicate(
            (widget) =>
                widget is TextFormField &&
                widget.controller == controller.referenceCtrl,
          );
          await expectReachable(tester, reference);
          final keyboardHeight = landscape ? 290.0 : 160.0;
          tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
          await tester.enterText(reference, 'Mobile draft');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final save = find.widgetWithText(
            FilledButton,
            (editing ? 'Update' : 'Save').tr,
          );
          final cancel = find.text('Cancel'.tr);
          if (landscape) {
            await expectReachable(tester, save);
            expect(
              tester.getRect(save).bottom,
              lessThanOrEqualTo(size.height - keyboardHeight),
            );
            controller.amountCtrl.text = '0';
            await tester.tap(save);
            await tester.pumpAndSettle();
            expect(find.text('Enter a valid amount'.tr), findsOneWidget);
            await expectReachable(tester, cancel);
            expect(
              tester.getRect(cancel).bottom,
              lessThanOrEqualTo(size.height - keyboardHeight),
            );
          }
          FocusManager.instance.primaryFocus?.unfocus();
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          expect(controller.referenceCtrl.text, 'Mobile draft');
          await expectReachable(tester, save);
          await expectReachable(tester, cancel);
          await tester.tap(cancel);
          await tester.pumpAndSettle();
        }
        expect(payments.createCalls, isEmpty);
        expect(payments.updateCalls, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('sales history opens a readable record at $size', (
      tester,
    ) async {
      final invoice = size.width == 320
          ? 'វិក្កយបត្រលក់សម្រាប់អតិថិជនថ្មី'
          : 'SALE-1';
      final sales = SaleTestSaleService()
        ..sales = [
          {
            ...saleJson(1, invoice: invoice),
            'sale_items': [
              {
                'product': saleProductJson(1, 'Water'),
                'qty': 2,
                'sale_price': '5.00',
                'subtotal': '10.00',
              },
            ],
          },
        ];
      SaleListController.invalidateCache();
      Get.put(SaleListController(service: sales));
      await pumpSalesPage(
        tester,
        SaleListScreen(),
        size: size,
        dark: dark,
        locale: locale,
        textScale: scale,
        desktopShell: true,
        route: '/sale-list',
        getPages: [
          GetPage(
            name: '/sale-list-detail',
            page: () => const SaleListDetailWidget(),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await expectReachable(tester, find.text('New Sale'.tr));
      final search = find.byType(TextField);
      await expectReachable(tester, search);
      await tester.enterText(search, invoice);
      await tester.pumpAndSettle();
      final record = find.descendant(
        of: find.byType(SaleCardWidget),
        matching: find.text(invoice),
      );
      await expectReachable(tester, find.byType(SaleCardWidget));
      await expectReachable(tester, record);
      await tester.tap(record);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/sale-list-detail');
      for (final value in [invoice, r'2 × $5.00', r'$12.50']) {
        await expectReachable(tester, find.text(value).first);
      }
      await expectReachable(tester, find.text('New Sale'.tr));
      final delete = find.widgetWithText(TextButton, 'Delete'.tr);
      await expectReachable(tester, delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.text('Do you want to delete this sale?'.tr), findsOneWidget);
      await expectReachable(tester, find.widgetWithText(FilledButton, 'Ok'));
      await expectReachable(
        tester,
        find.widgetWithText(OutlinedButton, 'Cancel'),
      );
      expect(sales.deleteCalls, isEmpty);
    });
  }
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
          size: detail ? const Size(844, 390) : const Size(320, 568),
          locale: const Locale('km', 'KH'),
          textScale: 2,
          desktopShell: true,
          route: detail ? '/sale-list-detail' : '/payment-success',
        );
        Get.to(
          () => detail
              ? const SaleListDetailWidget()
              : PaymentSuccessWidget(exportController: fake),
          arguments: detail
              ? {...saleJson(1), 'invoice_no': longValue}
              : {...receipt_fixtures.receipt, 'reference_no': longValue},
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
      ['Invoice', 'POS-42'],
      ['Reference No', 'REF-7'],
      ['Tea', r'2 × $3.00 = $6.00'],
      ['Lime', r'1 × $4.00 = $4.00'],
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
    expect(find.text('POS-42'), findsOneWidget);
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
        NavigationSaleController(sales),
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
  for (final (route, size, desktop) in [
    ('/sale?source=home', const Size(844, 390), false),
    ('/sale', const Size(840, 479), false),
    ('/sale', const Size(840, 480), true),
    ('/supplier', const Size(844, 390), true),
  ]) {
    testWidgets('sidebar scope for $route at $size', (tester) async {
      await pumpSalesPage(
        tester,
        Builder(
          builder: (context) => Text(
            DesktopAppShell.isVisible(context)
                ? 'Desktop scope'
                : 'Mobile scope',
          ),
        ),
        size: size,
        route: route,
        desktopShell: true,
      );
      expect(
        find.text(desktop ? 'Desktop scope' : 'Mobile scope'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
  for (final size in [
    const Size(375, 667),
    const Size(390, 844),
    const Size(844, 390),
    const Size(932, 430),
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
            'sales navigation placement $route $size dark=$dark km=$khmer',
            (tester) async {
              final sales = SaleTestSaleService();
              final payments = SaleTestPaymentService();
              Get.put<SaleController>(NavigationSaleController(sales));
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
                desktopShell: true,
                route: route,
              );
              expect(
                find.byType(CustomAppBar),
                desktop ? findsNothing : findsOneWidget,
              );
              expect(find.byType(AppPage), findsOneWidget);
              final header = find.byType(AppPageHeader);
              if (!desktop && ['/sale-list', '/sale-payment'].contains(route)) {
                expect(header, findsNothing);
                expect(
                  find.text(
                    (route == '/sale-list' ? 'Sale List' : 'Payment').tr,
                  ),
                  findsOneWidget,
                );
              } else if (!desktop) {
                expect(tester.widget<AppPageHeader>(header).leading, isNull);
              } else if (![
                '/current-sale',
                '/payment-success',
              ].contains(route)) {
                expect(
                  tester.widget<AppPageHeader>(header).leading,
                  isA<IconButton>(),
                );
              } else {
                expect(header, findsOneWidget);
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}

final longMobileValue = List.filled(8, 'ទំនិញឈ្មោះវែងសម្រាប់ការលក់').join(' ');

SaleController seedCart({String? productName}) {
  final cart = Get.put<SaleController>(
    NavigationSaleController(SaleTestSaleService()),
  );
  final product = saleProductJson(1, productName ?? longMobileValue);
  cart.categories.add({
    'name': 'Drinks',
    'products': [
      product,
      for (var id = 2; id <= 8; id++) saleProductJson(id, 'Water $id'),
    ],
  });
  cart.addProduct(product);
  cart.customers.add({'id': 1, 'name': longMobileValue});
  cart.selectedCustomer.value = cart.customers.first;
  cart.paymentTypes.add({'id': 1, 'name': 'Cash'});
  cart.selectedPaymentType.value = cart.paymentTypes.first;
  return cart;
}

Future<void> expectReachable(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      120,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}
