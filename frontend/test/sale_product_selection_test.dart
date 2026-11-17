import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class SellingController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  testWidgets('exact barcode and clear-search keep selected quantities', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Drinks',
      'products': [
        saleProductJson(1, 'Water'),
        {...saleProductJson(2, 'Bread'), 'barcode': '999'},
      ],
    });
    ctr.addProduct(saleProductJson(1, 'Water'));
    await pumpSalesPage(tester, SaleScreen());
    await tester.enterText(find.byType(TextField), '12345');
    await tester.pumpAndSettle();
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Bread'), findsNothing);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(ctr.totalItems, 1);
    expect(find.text('Water'), findsOneWidget);
  });
  testWidgets('wide product grid stays lazy', (tester) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Drinks',
      'products': List.generate(100, (i) => saleProductJson(i, 'Product $i')),
    });
    await pumpSalesPage(
      tester,
      SaleScreen(),
      size: const Size(1440, 900),
      desktopShell: true,
    );
    expect(find.byType(SliverGrid), findsOneWidget);
    expect(find.text('Product 99'), findsNothing);
    await tester.tap(find.text('Product 0'));
    await tester.tap(find.text('Product 0'));
    await tester.pump();
    expect(ctr.totalItems, 2);
    expect(ctr.subtotal, 10);
  });
  testWidgets('products use shared page and natural cards on phones', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Drinks',
      'products': List.generate(100, (i) => saleProductJson(i, 'Product $i')),
    });
    await pumpSalesPage(tester, SaleScreen());
    expect(find.byType(AppPage), findsOneWidget);
    expect(find.byType(AppPageHeader), findsOneWidget);
    expect(find.text('Product 99'), findsNothing);
    await tester.tap(find.text('Product 0'));
    await tester.pump();
    expect(ctr.totalItems, 1);
    expect(tester.takeException(), isNull);
  });
}
