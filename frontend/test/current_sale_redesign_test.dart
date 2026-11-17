import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class CartController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
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
  testWidgets('empty cart has shared page and back action', (tester) async {
    Get.put<SaleController>(CartController());
    await pumpSalesPage(tester, CurrentSaleWidget());
    expect(find.byType(AppPage), findsOneWidget);
    expect(find.text('Draft'), findsNothing);
    expect(find.text('Back to products'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
