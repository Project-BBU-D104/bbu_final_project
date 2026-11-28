import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:get/get.dart';

import 'customer_test_support.dart' show setUpCustomerTests;
import 'sale_test_support.dart';
import 'theme_controller_test.dart' show FakeStorageService;

class QuietLayoutController extends SaleController {
  QuietLayoutController(FakeStorageService preferences)
    : super(storageService: preferences);

  @override
  Future<void> loadProductCategories() async {}
  @override
  Future<void> loadCustomers() async {}
  @override
  Future<void> loadPaymentTypes() async {}
  @override
  Future<void> loadCurrency() async {}
}

class DelayedLayoutStorage extends FakeStorageService {
  final firstWrite = Completer<void>();
  int startedWrites = 0;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {
    startedWrites++;
    if (startedWrites == 1) await firstWrite.future;
    await super.writeStorage(key, value);
  }
}

Finder layoutItem(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byType(CheckedPopupMenuItem<int>),
);

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  test(
    'layout preference restores and preserves columns in list view',
    () async {
      final preferences = FakeStorageService();
      final first = QuietLayoutController(preferences)..onInit();
      expect(first.productGridView.value, isNull);
      expect(first.productGridColumns.value, 2);

      await first.setProductLayout(grid: true, columns: 4);
      final grid = QuietLayoutController(preferences)..onInit();
      expect(grid.productGridView.value, isTrue);
      expect(grid.productGridColumns.value, 4);

      await grid.setProductLayout(grid: false);
      final list = QuietLayoutController(preferences)..onInit();
      expect(list.productGridView.value, isFalse);
      expect(list.productGridColumns.value, 4);
    },
  );

  test('invalid saved layout values keep the adaptive defaults', () {
    final preferences = FakeStorageService()
      ..values[StorageKey.saleLayout] = {'grid': 'yes', 'columns': 99};
    final controller = QuietLayoutController(preferences)..onInit();
    expect(controller.productGridView.value, isNull);
    expect(controller.productGridColumns.value, 2);
  });

  test('rapid changes save the latest layout in order', () async {
    final preferences = DelayedLayoutStorage();
    final controller = QuietLayoutController(preferences)..onInit();
    final first = controller.setProductLayout(grid: true, columns: 4);
    final second = controller.setProductLayout(grid: false);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.startedWrites, 1);
    preferences.firstWrite.complete();
    await Future.wait([first, second]);
    expect(preferences.values[StorageKey.saleLayout], {
      'grid': false,
      'columns': 4,
    });
  });

  testWidgets('layout menu choice is restored on reopening Sale', (
    tester,
  ) async {
    final preferences = FakeStorageService();
    final first = Get.put<SaleController>(QuietLayoutController(preferences));
    first.categories.add({
      'name': 'Products',
      'products': [saleProductJson(1, 'Water')],
    });
    await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    await tester.tap(layoutItem('Grid view'));
    await tester.pumpAndSettle();
    expect(preferences.values[StorageKey.saleLayout], {
      'grid': true,
      'columns': 2,
    });

    await tester.pumpWidget(const SizedBox());
    await Get.delete<SaleController>(force: true);
    final restored = Get.put<SaleController>(
      QuietLayoutController(preferences),
    );
    restored.categories.add({
      'name': 'Products',
      'products': [saleProductJson(1, 'Water')],
    });
    await pumpSalesPage(tester, SaleScreen(), size: const Size(390, 844));
    expect(restored.productGridView.value, isTrue);
    expect(
      tester.widget<CardItemWidget>(find.byType(CardItemWidget)).naturalGrid,
      isTrue,
    );
    await tester.tap(find.byTooltip('Layout'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckedPopupMenuItem<int>>(layoutItem('Grid view')).checked,
      isTrue,
    );
  });
}
