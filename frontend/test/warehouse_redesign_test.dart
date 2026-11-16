import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/warehouse/warehouse_screen.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_card_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_table_widget.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'warehouse_test_support.dart';

void main() {
  setUp(setUpWarehouseTests);
  tearDown(() => Get.reset());
  WarehouseController register([FakeWarehouseService? service]) =>
      Get.put(WarehouseController(service: service ?? FakeWarehouseService()));
  for (final width in [799.0, 800.0]) {
    testWidgets('warehouse content breakpoint $width', (tester) async {
      register();
      await pumpWarehouseHost(
        tester,
        size: const Size(1440, 1000),
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width + 64, child: WarehouseScreen()),
        ),
      );
      expect(
        find.byType(WarehouseTableWidget),
        width == 800 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('initial failure shows Retry without empty success', (
    tester,
  ) async {
    final s = FakeWarehouseService()..failGet = true;
    register(s);
    await pumpWarehouseHost(tester, home: WarehouseScreen());
    expect(
      find.text('Unable to load warehouses. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('No warehouses yet'), findsNothing);
    s.failGet = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
  });
  testWidgets('empty dataset and no matches have distinct recovery', (
    tester,
  ) async {
    final s = FakeWarehouseService()..items = [];
    final c = register(s);
    await pumpWarehouseHost(tester, home: WarehouseScreen());
    expect(find.text('No warehouses yet'), findsOneWidget);
    s.items = [warehouseJson(1, 'Alpha')];
    await c.onRefresh();
    Get.find<SearchController>().keyword.value = 'missing';
    await tester.pumpAndSettle();
    expect(find.text('No matching warehouses'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    expect(s.getCalls, 2);
  });
  testWidgets('initial loading and retained records during refresh failure', (
    tester,
  ) async {
    final gate = Completer<dynamic>();
    final s = FakeWarehouseService();
    final c = register(s);
    await pumpWarehouseHost(tester, home: WarehouseScreen());
    s.getGate = gate;
    final refreshing = c.onRefresh();
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    gate.complete(s.items);
    await refreshing;
    await tester.pumpAndSettle();
    s.getGate = null;
    s.failGet = true;
    await c.onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
  for (final width in [840.0, 1024.0]) {
    testWidgets(
      'desktop shell uses available content and one app bar at $width',
      (tester) async {
        register();
        await pumpWarehouseHost(
          tester,
          home: WarehouseScreen(),
          size: Size(width, 1000),
        );
        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(find.byType(CustomAppBar), findsNothing);
        expect(
          find.byType(WarehouseTableWidget),
          width == 840 ? findsNothing : findsOneWidget,
        );
        if (width == 840) {
          expect(find.byType(WarehouseCardWidget), findsWidgets);
        }
      },
    );
  }
  testWidgets('warehouse row opens registered detail and newest data', (
    tester,
  ) async {
    final c = register();
    await pumpWarehouseHost(tester, home: WarehouseScreen());
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.warehouseDetail);
    c.warehouseList[0] = warehouseJson(1, 'Newest name');
    await tester.pumpAndSettle();
    expect(find.text('Newest name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final detail in [false, true]) {
    testWidgets(
      '${detail ? 'detail deletion returns to' : 'list deletion retains'} list route',
      (tester) async {
        final s = FakeWarehouseService();
        register(s);
        await pumpWarehouseHost(tester, home: WarehouseScreen());
        if (detail) {
          await tester.tap(find.text('Alpha'));
          await tester.pumpAndSettle();
        }
        await tester.tap(
          detail ? find.text('Delete') : find.byTooltip('Delete').first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ok'));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.warehouse);
        expect(s.deleteCalls, 1);
        expect(find.text('Alpha'), findsNothing);
      },
    );
  }
  testWidgets(
    'null stock relations and invalid detail argument remain usable',
    (tester) async {
      final s = FakeWarehouseService()
        ..items = [
          {
            ...warehouseJson(1, 'Alpha'),
            'warehouse_stock': [
              null,
              {'product': null},
              {
                'product': {'category': null},
              },
            ],
          },
        ];
      final c = register(s);
      await pumpWarehouseHost(tester, home: WarehouseScreen());
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Get.back();
      await tester.pumpAndSettle();
      Get.toNamed(AppRoutes.warehouseDetail, arguments: 'invalid');
      await tester.pumpAndSettle();
      expect(find.text('Warehouse unavailable'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(tester.takeException(), isNull);
      expect(identical(c, Get.find<WarehouseController>()), true);
    },
  );
  testWidgets('successful edit shows latest name on detail', (tester) async {
    final c = register();
    await pumpWarehouseHost(tester, home: WarehouseScreen());
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    c.warehouseNameController.text = 'Edited Alpha';
    tester.widget<AppFormActions>(find.byType(AppFormActions)).onSave!();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.warehouseDetail);
    expect(find.text('Edited Alpha'), findsOneWidget);
  });
  testWidgets('keyboard row activation navigates', (tester) async {
    register();
    await pumpWarehouseHost(
      tester,
      home: WarehouseScreen(),
      size: const Size(1440, 1000),
    );
    final button = find.byTooltip('Alpha').first;
    Focus.of(tester.element(button)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.warehouseDetail);
  });
  for (final width in [390.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final locale in [
        const Locale('en', 'US'),
        const Locale('km', 'KH'),
      ]) {
        testWidgets(
          'warehouse list/detail $width dark=$dark ${locale.languageCode} large text',
          (tester) async {
            final longName = List.filled(12, 'Warehouse Phnom Penh').join(' ');
            register(
              FakeWarehouseService()..items = [warehouseJson(1, longName)],
            );
            await pumpWarehouseHost(
              tester,
              home: WarehouseScreen(),
              size: Size(width, 1000),
              dark: dark,
              locale: locale,
              textScale: 2,
            );
            expect(tester.takeException(), isNull);
            expect(find.byType(WarehouseTableWidget), findsNothing);
            await tester.tap(find.text(longName));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
