import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class MatrixSaleController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  test('selling copy has both translations', () {
    for (final key in [
      'Confirm payment',
      'Charge @amount to @customer using @method?',
      'Unable to load products. Please try again.',
      'Unable to load customers. Please try again.',
      'Unable to load payment types. Please try again.',
      'Unable to load currency. Please try again.',
      'Unable to complete payment. Please try again.',
      'Review checkout',
      'Retry checkout',
      'Sales history',
      'Dismiss conflicting checkout',
      'Checkout requires a backend upgrade.',
      'Unable to save checkout. Please try again.',
      'Add @name, quantity @quantity',
      'Current Sale',
      'Back to products',
      'Payment successful',
      'Receipt unavailable',
      'Quantity: @quantity',
      'Continue · @quantity · @total',
      'Export Receipt',
      'Back to Sale',
      'Sale Receipt @id',
    ]) {
      expect(enUS.containsKey(key), isTrue, reason: 'English $key');
      expect(kmKH.containsKey(key), isTrue, reason: 'Khmer $key');
    }
  });
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(1440, 900),
  ]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            'selling matrix $size dark=$dark khmer=$khmer scale=$scale',
            (tester) async {
              final ctr = Get.put<SaleController>(MatrixSaleController());
              final name = List.filled(4, 'ទឹកផ្លែឈើ').join(' ');
              ctr.categories.add({
                'name': name,
                'products': [saleProductJson(1, name)],
              });
              ctr.addProduct(saleProductJson(1, name));
              ctr.customers.add({'id': 1, 'name': name});
              ctr.selectedCustomer.value = ctr.customers.first;
              ctr.paymentTypes.add({'id': 1, 'name': name});
              ctr.selectedPaymentType.value = ctr.paymentTypes.first;
              await pumpSalesPage(
                tester,
                SaleScreen(),
                size: size,
                dark: dark,
                locale: Locale(khmer ? 'km' : 'en', khmer ? 'KH' : 'US'),
                textScale: scale,
                desktopShell: true,
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await pumpSalesPage(
                tester,
                CurrentSaleWidget(),
                size: size,
                dark: dark,
                locale: Locale(khmer ? 'km' : 'en', khmer ? 'KH' : 'US'),
                textScale: scale,
                desktopShell: true,
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
