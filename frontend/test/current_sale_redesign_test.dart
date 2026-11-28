import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/screen/payment/sale_with_payment/widget/payment_method_card_widget.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class CartController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() => seedSaleCurrency(this);
}

void main() {
  testWidgets('order summary updates for all selected products', (
    tester,
  ) async {
    setUpCustomerTests();
    final ctr = Get.put<SaleController>(CartController());
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.addProduct({...saleProductJson(2, 'Bread'), 'sale_price': '7.00'});
    await pumpSalesPage(
      tester,
      CurrentSaleWidget(),
      size: const Size(390, 844),
    );

    final summary = find.byType(SummaryOrderWidget);
    expect(
      find.descendant(of: summary, matching: find.text('Order Summary')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('Total quantity')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text(r'$12.00')),
      findsOneWidget,
    );
    final quantity = find.descendant(of: summary, matching: find.text('2'));
    final total = find.descendant(of: summary, matching: find.text(r'$12.00'));
    expect(tester.getRect(total).right, tester.getRect(quantity).right);
    expect(tester.widget<Text>(total).textAlign, TextAlign.end);
    final increase = find.byTooltip('Increase quantity').first;
    await tester.ensureVisible(increase);
    await tester.tap(increase);
    await tester.pump();
    expect(
      find.descendant(of: summary, matching: find.text('3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text(r'$17.00')),
      findsOneWidget,
    );
    ctr.changeQuantity(2, -1);
    await tester.pump();
    expect(
      find.descendant(of: summary, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text(r'$10.00')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'cart amount appears at the top right and updates with quantity',
    (tester) async {
      setUpCustomerTests();
      final ctr = Get.put<SaleController>(CartController());
      seedSaleCurrency(ctr);
      ctr.addProduct(saleProductJson(1, 'Water'));
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: const Size(390, 844),
      );

      final name = find.text('Water');
      final amount = find.descendant(
        of: find.byType(CurrentSaleItemWidget),
        matching: find.text(r'$5.00'),
      );
      expect(tester.getTopLeft(amount).dy, tester.getTopLeft(name).dy);
      expect(
        tester.getTopLeft(amount).dx,
        greaterThan(tester.getTopLeft(name).dx),
      );
      expect(
        tester.getRect(amount).right,
        closeTo(
          tester.getRect(find.byType(CurrentSaleItemWidget)).right -
              AppSpacing.lg,
          1,
        ),
      );
      final increase = find.byTooltip('Increase quantity');
      await tester.ensureVisible(increase);
      await tester.tap(increase);
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(CurrentSaleItemWidget),
          matching: find.text(r'$10.00'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'product image is shown and checkout actions stay at the bottom',
    (tester) async {
      setUpCustomerTests();
      final ctr = Get.put<SaleController>(CartController());
      for (var i = 0; i < 8; i++) {
        ctr.addProduct({
          ...saleProductJson(i, 'Product $i'),
          if (i == 0) 'photo': 'https://example.com/product.png',
        });
      }
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      ctr.selectedPaymentType.value = ctr.paymentTypes.first;
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: const Size(390, 844),
      );

      final firstCard = find.byType(CurrentSaleItemWidget).first;
      final image = find.descendant(
        of: firstCard,
        matching: find.byType(AppCachedImage),
      );
      expect(
        tester.widget<AppCachedImage>(image).url,
        'https://example.com/product.png',
      );
      expect(
        tester.getRect(image).right,
        lessThan(tester.getRect(find.text('Product 0')).left),
      );

      final payment = find.widgetWithText(FilledButton, 'Payment');
      final paymentBefore = tester.getRect(payment);
      expect(find.text('Back to products'), findsNothing);
      expect(find.text('Current Sale'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(payment.hitTestable(), findsOneWidget);
      expect(paymentBefore.bottom, greaterThan(800));
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -1200),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(payment), paymentBefore);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'compact cart keeps image and footer usable with large Khmer text',
    (tester) async {
      setUpCustomerTests();
      final ctr = Get.put<SaleController>(CartController());
      ctr.addProduct(saleProductJson(1, 'ទំនិញសម្រាប់ការលក់'));
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      ctr.selectedPaymentType.value = ctr.paymentTypes.first;
      tester.view.viewPadding = const FakeViewPadding(bottom: 24);
      tester.view.padding = const FakeViewPadding(bottom: 24);
      addTearDown(tester.view.resetViewPadding);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewInsets);
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: const Size(320, 568),
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      final payment = find.widgetWithText(FilledButton, 'Payment'.tr);
      expect(payment.hitTestable(), findsOneWidget);
      expect(find.byTooltip('Back'.tr), findsOneWidget);
      expect(find.text('Back to products'.tr), findsNothing);
      expect(tester.getRect(payment).bottom, lessThanOrEqualTo(568 - 24));
      final increase = find.byTooltip('Increase quantity'.tr);
      await tester.ensureVisible(increase);
      await tester.tap(increase);
      await tester.pump();
      expect(ctr.totalItems, 2);
      expect(tester.takeException(), isNull);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(payment, findsNothing);
      tester.view.resetViewInsets();
      tester.view.padding = const FakeViewPadding(bottom: 24);
      await tester.pump();
      expect(payment.hitTestable(), findsOneWidget);
    },
  );
  for (final size in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets('customer and payment appear above cart at $size', (
      tester,
    ) async {
      setUpCustomerTests();
      final ctr = Get.put<SaleController>(CartController());
      ctr.addProduct(saleProductJson(1, 'Water'));
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      await pumpSalesPage(tester, CurrentSaleWidget(), size: size);
      final customer = tester.getRect(find.byType(SelectCustomerCardWidget));
      final payment = tester.getRect(find.byType(PaymentMethodCardWidget));
      final item = tester.getRect(find.byType(CurrentSaleItemWidget));
      expect(customer.bottom, lessThanOrEqualTo(payment.top));
      expect(payment.bottom, lessThan(item.top));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'desktop keeps an icon back action and locks it during checkout',
    (tester) async {
      final ctr = Get.put<SaleController>(CartController());
      ctr.addProduct(saleProductJson(1, 'Water'));
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: const Size(1440, 900),
        desktopShell: true,
        route: '/current-sale',
      );
      final back = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Back',
      );
      expect(back, findsOneWidget);
      expect(tester.widget<IconButton>(back).onPressed, isNotNull);
      expect(find.text('Current Sale'), findsNothing);
      expect(find.text('Back to products'), findsNothing);
      ctr.isConfirmingPayment.value = true;
      await tester.pump();
      expect(tester.widget<IconButton>(back).onPressed, isNull);
    },
  );
  testWidgets('cart sections use shared headings and surfaces', (tester) async {
    setUpCustomerTests();
    final ctr = Get.put<SaleController>(CartController());
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.customers.add({'id': 1, 'name': 'Dara'});
    ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
    await pumpSalesPage(
      tester,
      CurrentSaleWidget(),
      size: const Size(1440, 900),
    );
    expect(
      find.descendant(
        of: find.byType(CurrentSaleItemWidget),
        matching: find.byType(AppListCard),
      ),
      findsOneWidget,
    );
    for (final type in [SummaryOrderWidget, PaymentMethodCardWidget]) {
      expect(
        find.descendant(
          of: find.byType(type),
          matching: find.byType(AppSectionCard),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.byType(PaymentMethodCardWidget),
        matching: find.byType(AppFormSection),
      ),
      findsOneWidget,
    );
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text(r'$5.00'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(ctr.totalItems, 2);
    expect(find.text(r'$10.00'), findsNWidgets(2));
    await tester.tap(find.text('Select Customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dara'));
    await tester.pumpAndSettle();
    expect(ctr.selectedCustomer.value?['id'], 1);
  });
  testWidgets('confirmation disables quantity payment and selector controls', (
    tester,
  ) async {
    setUpCustomerTests();
    final ctr = Get.put<SaleController>(CartController());
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.isConfirmingPayment.value = true;
    await pumpSalesPage(tester, CurrentSaleWidget());
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Increase quantity',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Decrease quantity',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Back to products'), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  testWidgets('cold current sale entry recovers without a controller', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: const Locale('en', 'US'),
        initialRoute: '/current-sale',
        getPages: [
          GetPage(name: '/current-sale', page: () => CurrentSaleWidget()),
          GetPage(
            name: '/sale',
            page: () => const Scaffold(body: Text('Products recovery')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppPage), findsOneWidget);
    expect(find.byType(AppPageHeader), findsOneWidget);
    expect(find.text('No products selected'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Back to products'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Back to products'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/sale');
    expect(find.text('Products recovery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('customer section updates late lookup failures and recovery', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(CartController());
    ctr.addProduct(saleProductJson(1, 'Water'));
    await pumpSalesPage(
      tester,
      CurrentSaleWidget(),
      size: const Size(1440, 900),
    );
    ctr.customerLoadError.value = 'Customer lookup offline';
    await tester.pump();
    expect(find.text('Customer lookup offline'), findsOneWidget);
    ctr.customerLoadError.value = '';
    await tester.pump();
    expect(find.text('Customer lookup offline'), findsNothing);
  });
  testWidgets(
    'compact landscape Khmer checkout keeps controls reachable at 2x',
    (tester) async {
      final ctr = Get.put<SaleController>(CartController());
      ctr.addProduct(
        saleProductJson(1, 'ទំនិញឈ្មោះវែងសម្រាប់ការលក់ និងការពិនិត្យ'),
      );
      ctr.selectedCustomer.value = {
        'id': 1,
        'name': 'អតិថិជនឈ្មោះវែងសម្រាប់ការពិនិត្យ',
      };
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      await pumpSalesPage(
        tester,
        CurrentSaleWidget(),
        size: const Size(844, 390),
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      for (final label in ['Increase quantity', 'Decrease quantity']) {
        final control = find.byTooltip(label.tr);
        await tester.ensureVisible(control);
        await tester.tap(control);
        await tester.pump();
      }
      expect(ctr.totalItems, 1);
      expect(find.text('Back to products'.tr), findsNothing);
      expect(find.text('Payment'.tr).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty cart has shared page and back action', (tester) async {
    Get.put<SaleController>(CartController());
    await pumpSalesPage(tester, CurrentSaleWidget());
    expect(find.byType(AppPage), findsOneWidget);
    expect(find.text('Draft'), findsNothing);
    expect(find.text('Back to products'), findsNothing);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
