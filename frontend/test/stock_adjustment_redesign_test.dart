import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/screen/stock/stock_adjustment/stock_adjustment_screen.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_detail_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_card_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/stock_adjustment_table_widget.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:get/get.dart';
import 'stock_adjustment_test_support.dart';

void main() {
  setUp(setUpAdjustmentTests);
  tearDown(Get.reset);
  late StockAdjustmentController c;
  late FakeStockAdjustmentService s;
  setUp(() {
    s = FakeStockAdjustmentService();
    c = Get.put(
      StockAdjustmentController(
        service: s,
        warehouseStockService: FakeAdjustmentStockService(),
      ),
    );
  });
  testWidgets(
    'invalid detail arguments show unavailable state without actions',
    (tester) async {
      await pumpAdjustmentHost(tester, home: StockAdjustmentDetailWidget());
      expect(find.text('Stock adjustment unavailable'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'list separates empty, no matches, failure and retained records',
    (tester) async {
      await pumpAdjustmentHost(tester, home: StockAdjustmentScreen());
      c.searchStockAdjustment('missing');
      await tester.pumpAndSettle();
      expect(find.text('No matching stock adjustments'), findsOneWidget);
      c.searchStockAdjustment('rice');
      s.failGet = true;
      await c.onRefresh();
      await tester.pumpAndSettle();
      expect(
        find.text('Unable to load stock adjustments. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Rice'), findsOneWidget);
      s.failGet = false;
      s.items = [];
      await c.onRefresh();
      await tester.pumpAndSettle();
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('No stock adjustments yet'), findsOneWidget);
    },
  );
  for (final dark in [false, true]) {
    for (final locale in [const Locale('en', 'US'), const Locale('km', 'KH')]) {
      for (final width in [390.0, 840.0, 1024.0, 1440.0]) {
        testWidgets('list shell matrix $dark $locale $width', (tester) async {
          s.items = [
            {...adjustmentJson(1), 'product': null, 'warehouse': null},
            adjustmentJson(2, type: 'decrease'),
          ];
          await c.onRefresh();
          await pumpAdjustmentHost(
            tester,
            home: StockAdjustmentScreen(),
            size: Size(width, 900),
            dark: dark,
            locale: locale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('large text forces cards and direction has signed quantity', (
    tester,
  ) async {
    await pumpAdjustmentHost(
      tester,
      home: StockAdjustmentScreen(),
      size: const Size(1440, 900),
      textScale: 2,
    );
    expect(find.byType(StockAdjustmentCardWidget), findsOneWidget);
    expect(find.byType(StockAdjustmentTableWidget), findsNothing);
    expect(find.text('Increase +3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [799.0, 800.0]) {
    testWidgets('available content width boundary $width', (tester) async {
      // AppPage uses two wide gutters of 32, so viewport = content + 64.
      await pumpAdjustmentHost(
        tester,
        home: StockAdjustmentScreen(),
        size: Size(width + 64, 900),
        shell: false,
      );
      expect(
        find.byType(StockAdjustmentTableWidget),
        width == 800 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(StockAdjustmentCardWidget),
        width == 799 ? findsOneWidget : findsNothing,
      );
    });
  }
  testWidgets(
    'deletion cancel and failure stay; detail success returns to list',
    (tester) async {
      await pumpAdjustmentHost(tester, home: StockAdjustmentScreen());
      c.gotoStockAdjustmentDetailScreen(s.items.first);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.stockAdjustmentDetail);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.stockAdjustmentDetail);
      expect(s.deleteCalls, 0);
      s.failWrite = true;
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.stockAdjustmentDetail);
      expect(
        find.text('Unable to delete stock adjustment. Please try again.'),
        findsOneWidget,
      );
      s.failWrite = false;
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.stockAdjustment);
      expect(s.deleteCalls, 2);
      expect(find.text('No stock adjustments yet'), findsOneWidget);
    },
  );
  testWidgets('list deletion never pops list', (tester) async {
    await pumpAdjustmentHost(tester, home: StockAdjustmentScreen());
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockAdjustment);
    expect(s.deleteCalls, 1);
  });
  testWidgets('detail uses refreshed movement and tolerates absent metadata', (
    tester,
  ) async {
    await pumpAdjustmentHost(tester, home: StockAdjustmentScreen());
    c.gotoStockAdjustmentDetailScreen({
      ...adjustmentJson(1),
      'product': null,
      'warehouse': null,
    });
    await tester.pumpAndSettle();
    expect(find.text('Increase +3'), findsOneWidget);
    s.items = [
      {
        ...adjustmentJson(1, qty: 8),
        'product': null,
        'warehouse': null,
        'reason': 'Retained historical reason',
      },
    ];
    await c.onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('Increase +8'), findsOneWidget);
    expect(find.text('Created at: -'), findsOneWidget);
    expect(find.text('User: -'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Enter opens table reference detail', (tester) async {
    await pumpAdjustmentHost(
      tester,
      home: StockAdjustmentScreen(),
      size: const Size(1440, 900),
    );
    final reference = find.widgetWithText(TextButton, 'ADJ-1');
    Focus.of(tester.element(reference)).requestFocus();
    // Focus the semantic button itself, not an unrelated ancestor scope.
    final buttonFocus = find
        .descendant(of: reference, matching: find.byType(Focus))
        .first;
    tester.widget<Focus>(buttonFocus).focusNode?.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockAdjustmentDetail);
  });
  for (final dark in [false, true]) {
    for (final locale in [const Locale('en', 'US'), const Locale('km', 'KH')]) {
      for (final width in [390.0, 1024.0]) {
        testWidgets('detail shell and large text $dark $locale $width', (
          tester,
        ) async {
          await pumpAdjustmentHost(
            tester,
            home: StockAdjustmentScreen(),
            size: Size(width, 900),
            dark: dark,
            locale: locale,
            textScale: 2,
          );
          c.gotoStockAdjustmentDetailScreen({
            ...adjustmentJson(999),
            'product': null,
            'warehouse': null,
            'user': null,
            'reason': List.filled(20, 'Historical reason').join(' '),
          });
          await tester.pumpAndSettle();
          expect(find.byType(StockAdjustmentDetailWidget), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
