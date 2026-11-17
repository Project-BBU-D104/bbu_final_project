import 'package:flutter/material.dart';
import 'dart:ui' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
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
  testWidgets(
    'product button announces price and stock without duplicate actions',
    (tester) async {
      final ctr = Get.put<SaleController>(SellingController());
      ctr.currency.value = {'symbol': r'$', 'code': 'USD'};
      ctr.categories.add({
        'name': 'Drinks',
        'products': [saleProductJson(1, 'Water')],
      });
      await pumpSalesPage(tester, SaleScreen(), size: const Size(1440, 900));
      final button = find.bySemanticsLabel('Add Water, quantity 0');
      expect(button, findsOneWidget);
      final semantics = tester.getSemantics(button).getSemanticsData();
      expect(semantics.value, contains(r'$5.00'));
      expect(semantics.value, contains('Sold out'));
      final node = tester.getSemantics(button);
      expect(semantics.hasAction(SemanticsAction.tap), isTrue);
      expect(node.childrenCount, 0);
    },
  );
  testWidgets(
    'compact landscape Khmer products keep cart action reachable at 2x',
    (tester) async {
      final ctr = Get.put<SaleController>(SellingController());
      final product = saleProductJson(
        1,
        'ទំនិញឈ្មោះវែងសម្រាប់ការលក់ និងការពិនិត្យ',
      );
      ctr.categories.add({
        'name': 'Drinks',
        'products': [product],
      });
      ctr.addProduct(product);
      await pumpSalesPage(
        tester,
        SaleScreen(),
        size: const Size(844, 390),
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      await tester.scrollUntilVisible(
        find.byType(CardItemWidget),
        100,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(find.text(product['name'] as String));
      await tester.pumpAndSettle();
      expect(
        find.text(product['name'] as String).hitTestable(),
        findsOneWidget,
      );
      expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('product tiles use shared list surfaces', (tester) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Drinks',
      'products': [saleProductJson(1, 'Water')],
    });
    await pumpSalesPage(tester, SaleScreen(), size: const Size(1440, 900));
    final tile = find.byType(CardItemWidget);
    expect(
      find.descendant(of: tile, matching: find.byType(AppListCard)),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AppListCard>(
            find.descendant(of: tile, matching: find.byType(AppListCard)),
          )
          .margin,
      EdgeInsets.zero,
    );
    await tester.tap(tile);
    await tester.pump();
    expect(ctr.totalItems, 1);
    expect(ctr.subtotal, 5);
    expect(find.bySemanticsLabel('Add Water, quantity 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
