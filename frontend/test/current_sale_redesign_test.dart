import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/payment/sale_with_payment/widget/payment_method_card_widget.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class CartController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  testWidgets('cart sections use shared headings and surfaces', (tester) async {
    setUpCustomerTests();
    final ctr = Get.put<SaleController>(CartController());
    ctr.currency.value = {'symbol': r'$', 'code': 'USD'};
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
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Back to products'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
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
      for (final label in ['Back to products', 'Payment']) {
        final control = find.text(label.tr);
        await tester.ensureVisible(control);
        expect(control.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty cart has shared page and back action', (tester) async {
    Get.put<SaleController>(CartController());
    await pumpSalesPage(tester, CurrentSaleWidget());
    expect(find.byType(AppPage), findsOneWidget);
    expect(find.text('Draft'), findsNothing);
    expect(find.text('Back to products'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
