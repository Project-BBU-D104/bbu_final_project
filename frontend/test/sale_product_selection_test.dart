import 'package:flutter/material.dart';
import 'dart:ui' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

class SellingController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() => seedSaleCurrency(this);
}

Finder layoutOption(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byType(CheckedPopupMenuItem<int>),
);

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);
  for (final grid in [false, true]) {
    testWidgets('product cards use their own currencies grid=$grid', (
      tester,
    ) async {
      final ctr = Get.put<SaleController>(SellingController());
      ctr.productGridView.value = grid;
      ctr.currencies.clear();
      ctr.currency.value = {'code': 'KHR', 'symbol': '៛'};
      ctr.categories.add({
        'name': 'Products',
        'products': [
          {
            ...saleProductJson(1, 'Water'),
            'sale_price': '1000',
            'currency': {'id': 1, 'code': 'KHR', 'symbol': '៛'},
          },
          {
            ...saleProductJson(2, 'Books'),
            'sale_price': '6',
            'currency_id': 2,
            'currency': {'id': 2, 'code': 'USD', 'symbol': r'$'},
          },
        ],
      });
      await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
      expect(find.text('៛1,000'), findsOneWidget);
      expect(find.text(r'$6.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final grid in [false, true]) {
    testWidgets('selected quantity appears in a top-right chip grid=$grid', (
      tester,
    ) async {
      final ctr = Get.put<SaleController>(SellingController());
      ctr.productGridView.value = grid;
      ctr.categories.add({
        'name': 'Products',
        'products': [saleProductJson(1, 'Water')],
      });
      await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
      final card = find.byType(CardItemWidget);
      final chip = find.descendant(
        of: card,
        matching: find.byType(AppStatusBadge),
      );
      expect(chip, findsNothing);
      expect(find.text('Quantity: 0'), findsNothing);

      await tester.tap(card);
      await tester.pump();
      expect(tester.widget<AppStatusBadge>(chip).label, '1');
      expect(
        tester.getRect(chip).center.dx,
        greaterThan(tester.getRect(card).center.dx),
      );
      expect(find.bySemanticsLabel('Add Water, quantity 1'), findsOneWidget);
      ctr.changeQuantity(1, -1);
      await tester.pump();
      expect(chip, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('product loading indicator is centered below search', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.isLoading.value = true;
    await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
    final indicator = tester.getCenter(find.byType(CircularProgressIndicator));
    final searchBottom = tester.getRect(find.byType(AppSearchField)).bottom;
    final scrollBottom = tester.getRect(find.byType(CustomScrollView)).bottom;
    expect(
      indicator.dy,
      closeTo((searchBottom + AppSpacing.lg + scrollBottom) / 2, 1),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('sale layout controls switch list and grid without losing cart', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    final products = List.generate(6, (i) => saleProductJson(i, 'Product $i'));
    ctr.categories.add({'name': 'Products', 'products': products});
    ctr.addProduct(products.first);
    await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
    await tester.enterText(find.byType(TextField), 'Product');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CardItemWidget>(find.byType(CardItemWidget).first)
          .naturalGrid,
      isFalse,
    );

    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    await tester.tap(layoutOption('Grid view'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CardItemWidget>(find.byType(CardItemWidget).first)
          .naturalGrid,
      isTrue,
    );
    expect(
      tester.getTopLeft(find.text('Product 1')).dx,
      greaterThan(tester.getTopLeft(find.text('Product 0')).dx),
    );
    expect(ctr.totalItems, 1);
    expect(ctr.searchCtr.keyword.value, 'Product');

    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    await tester.tap(layoutOption('List view'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CardItemWidget>(find.byType(CardItemWidget).first)
          .naturalGrid,
      isFalse,
    );
    expect(ctr.totalItems, 1);
    expect(ctr.searchCtr.keyword.value, 'Product');
    expect(tester.takeException(), isNull);
  });
  testWidgets('column selector controls the grid on wide screens', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Products',
      'products': List.generate(6, (i) => saleProductJson(i, 'Product $i')),
    });
    await pumpSalesPage(tester, SaleScreen(), size: const Size(800, 900));
    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    await tester.tap(layoutOption('4 columns'));
    await tester.pumpAndSettle();
    expect(ctr.productGridColumns.value, 4);
    expect(find.byTooltip('Layout'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Product 2')).dx,
      greaterThan(tester.getTopLeft(find.text('Product 1')).dx),
    );
    tester.view.physicalSize = const Size(320, 900);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    final unavailable = tester.widget<CheckedPopupMenuItem<int>>(
      layoutOption('3 columns'),
    );
    expect(unavailable.enabled, isFalse);
    expect(ctr.productGridColumns.value, 4);
    await tester.tapAt(const Offset(10, 600));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    final selected = tester.widget<CheckedPopupMenuItem<int>>(
      layoutOption('4 columns'),
    );
    expect(selected.checked, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('grid remains usable with large Khmer text on a phone', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    ctr.categories.add({
      'name': 'Products',
      'products': List.generate(
        4,
        (i) => saleProductJson(i, 'ទំនិញសម្រាប់ការលក់ $i'),
      ),
    });
    await pumpSalesPage(
      tester,
      SaleScreen(),
      size: const Size(320, 568),
      locale: const Locale('km', 'KH'),
      textScale: 2,
    );
    await tester.tap(find.byTooltip('ទម្រង់បង្ហាញ'));
    await tester.pumpAndSettle();
    await tester.tap(layoutOption('បង្ហាញជាក្រឡា'));
    await tester.pumpAndSettle();
    expect(ctr.productGridView.value, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'checkout floats full width while the last product stays reachable',
    (tester) async {
      final ctr = Get.put<SaleController>(SellingController());
      final products = List.generate(
        12,
        (i) => saleProductJson(i, 'Product $i'),
      );
      ctr.categories.add({'name': 'Products', 'products': products});
      ctr.addProduct(products.first);
      await pumpSalesPage(tester, SaleScreen(), size: const Size(375, 667));

      final footer = find.byType(PaymentFooterWidget);
      final button = find.descendant(
        of: footer,
        matching: find.byType(FilledButton),
      );
      final scrollView = find.byType(CustomScrollView);
      expect(tester.getSize(button).width, tester.getSize(scrollView).width);
      expect(
        find.descendant(
          of: button,
          matching: find.byIcon(Icons.arrow_forward_rounded),
        ),
        findsOneWidget,
      );
      expect(find.text('Qty: 1'), findsOneWidget);
      expect(find.text(r'Amount: $5.00'), findsOneWidget);
      expect(find.text('Exchange rate: —'), findsOneWidget);
      ctr.addProduct(products.first);
      await tester.pump();
      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text(r'Amount: $10.00'), findsOneWidget);
      ctr.currency.value = {
        'code': 'KHR',
        'symbol': '៛',
        'exchange_rate': 4000,
      };
      ctr.currencies.assignAll([
        {'code': 'USD', 'exchange_rate': 1},
        {'code': 'KHR', 'exchange_rate': 4000},
      ]);
      await tester.pump();
      expect(find.text(r'Exchange rate: 1$ = 4,000៛'), findsOneWidget);
      final initialFooter = tester.getRect(button);

      await tester.drag(scrollView, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.getRect(button), initialFooter);
      final lastProduct = find.text('Product 11');
      expect(lastProduct.hitTestable(), findsOneWidget);
      expect(tester.getRect(lastProduct).bottom, lessThan(initialFooter.top));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('floating summary remains tappable on a small screen at 2x', (
    tester,
  ) async {
    final ctr = Get.put<SaleController>(SellingController());
    final products = List.generate(10, (i) => saleProductJson(i, 'Product $i'));
    ctr.categories.add({'name': 'Products', 'products': products});
    ctr.addProduct(products.first);
    ctr.currencies.assignAll([
      {'code': 'USD', 'exchange_rate': 1},
      {'code': 'KHR', 'exchange_rate': 4000},
    ]);
    await pumpSalesPage(
      tester,
      SaleScreen(),
      size: const Size(320, 568),
      locale: const Locale('km', 'KH'),
      textScale: 2,
    );
    final button = find.descendant(
      of: find.byType(PaymentFooterWidget),
      matching: find.byType(FilledButton),
    );
    expect(button.hitTestable(), findsOneWidget);
    final lastProduct = find.text('Product 9');
    for (var i = 0; i < 40; i++) {
      if (lastProduct.hitTestable().evaluate().isNotEmpty &&
          tester.getRect(lastProduct).bottom < tester.getRect(button).top) {
        break;
      }
      await tester.dragFrom(
        Offset(tester.getCenter(button).dx, tester.getTopLeft(button).dy - 16),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
    }
    expect(lastProduct.hitTestable(), findsOneWidget);
    expect(
      tester.getRect(lastProduct).bottom,
      lessThan(tester.getRect(button).top),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'product button announces price and stock without duplicate actions',
    (tester) async {
      final ctr = Get.put<SaleController>(SellingController());
      ctr.currency.value = {'symbol': r'$', 'code': 'USD'};
      ctr.categories.add({
        'name': 'Drinks',
        'products': [
          {
            ...saleProductJson(1, 'Water'),
            'currency': {'code': 'USD', 'symbol': r'$'},
          },
        ],
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
      expect(
        find.descendant(
          of: find.byType(PaymentFooterWidget),
          matching: find.text('ចំនួន៖ 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PaymentFooterWidget),
          matching: find.text(r'ចំនួនទឹកប្រាក់៖ $5.00'),
        ),
        findsOneWidget,
      );
      expect(find.text('អត្រាប្តូរប្រាក់៖ —'), findsOneWidget);
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
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Product 99'), findsNothing);
    await tester.tap(find.text('Product 0'));
    await tester.pump();
    expect(ctr.totalItems, 1);
    expect(tester.takeException(), isNull);
  });
}
