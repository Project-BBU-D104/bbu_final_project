import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_form_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/stock_transfer/stock_transfer_screen.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_table_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_detail_card_widget.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';
import 'stock_transfer_test_support.dart';

class _Storage implements IStorageService {
  @override
  bool hasRole(String role) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ProductTransferController c;
  late FakeProductTransferService s;
  setUp(() {
    initTransferEnvironment();
    Get.testMode = true;
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(_Storage());
    }
    final warehouses = TransferWarehouseController();
    warehouses.warehouseList.assignAll([
      {'id': 1, 'name': 'Source'},
      {'id': 2, 'name': 'Destination'},
    ]);
    Get.put<WarehouseController>(warehouses, permanent: true);
    s = FakeProductTransferService();
    c = Get.put(
      ProductTransferController(
        service: s,
        warehouseStockService: FakeTransferStockService(),
        onStockChanged: () async {},
      ),
      permanent: true,
    );
  });
  tearDown(() {
    Get.reset();
  });
  Future<void> host(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
    bool dark = false,
    bool khmer = false,
    bool shell = false,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: shell
              ? DesktopAppShell(route: AppRoutes.stockTransfer, child: child!)
              : child!,
        ),
        initialRoute: AppRoutes.stockTransfer,
        getPages: [
          GetPage(
            name: AppRoutes.stockTransfer,
            page: () => StockTransferScreen(),
          ),
          GetPage(
            name: AppRoutes.stockTransferDetail,
            page: () => StockDetailCardWidget(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'list distinguishes empty no matches failure and retained refresh',
    (tester) async {
      s.records = [];
      await c.onRefresh();
      await host(tester);
      expect(find.text('No stock transfers yet'), findsOneWidget);
      s.records = [transferJson(1)];
      await c.onRefresh();
      c.searchStockTransfer('absent');
      await tester.pumpAndSettle();
      expect(find.text('No matching stock transfers'), findsOneWidget);
      c.searchStockTransfer('');
      s.failList = true;
      await c.onRefresh();
      await tester.pumpAndSettle();
      expect(
        find.text('Unable to load stock transfers. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('TR-1'), findsOneWidget);
    },
  );
  testWidgets('initial loading and load failure are visible with retry', (
    tester,
  ) async {
    s.listGate = Completer<dynamic>();
    c.stockTransfer.clear();
    final pending = c.onRefresh();
    // Do not settle an intentionally pending progress indicator.
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(GetMaterialApp(home: StockTransferScreen()));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    s.listGate!.completeError(Exception('private'));
    await pending;
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to load stock transfers. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
  for (final content in [799.0, 800.0]) {
    testWidgets('content width $content chooses expected representation', (
      tester,
    ) async {
      // AppPage adds two wide gutters of 32 each.
      await host(tester, width: content + 64);
      expect(
        find.byType(
          content < 800 ? StockTransferCardWidget : StockTransferTableWidget,
        ),
        findsOneWidget,
      );
    });
  }
  testWidgets('large text falls back to cards', (tester) async {
    await host(tester, width: 1440, scale: 2);
    expect(find.byType(StockTransferCardWidget), findsOneWidget);
    expect(find.byType(StockTransferTableWidget), findsNothing);
  });
  testWidgets(
    'detail tolerates missing relations and shows newest record after edit',
    (tester) async {
      s.records = [
        transferJson(1)
          ..['from_warehouse'] = null
          ..['to_warehouse'] = null,
      ];
      await c.onRefresh();
      await host(tester);
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: s.records.single);
      await tester.pumpAndSettle();
      expect(find.text('Rice'), findsOneWidget);
      expect(tester.takeException(), isNull);
      c.stockTransfer.assignAll([
        {...transferJson(1, qty: 8), 'reference_no': 'NEW'},
      ]);
      await tester.pumpAndSettle();
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('Total quantity: 8'), findsOneWidget);
    },
  );
  testWidgets('fresh detail response supersedes stale list record', (
    tester,
  ) async {
    await host(tester);
    s.records = [transferJson(1, qty: 9)];
    await c.gotoStockTransferDetail(transferJson(1));
    await tester.pumpAndSettle();
    expect(find.text('Total quantity: 9'), findsOneWidget);
  });
  testWidgets('invalid detail argument shows unavailable state', (
    tester,
  ) async {
    await host(tester);
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: 'invalid');
    await tester.pumpAndSettle();
    expect(find.text('Stock transfer unavailable'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('transfer UTC date renders consistently near midnight', (
    tester,
  ) async {
    await host(tester);
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: transferJson(1));
    await tester.pumpAndSettle();
    final expected = DateFormatter.formatDate(
      DateTime.parse('2026-11-14T17:30:00.000Z').toLocal(),
    );
    expect(find.text('Transfer date: $expected'), findsOneWidget);
  });
  testWidgets('compact transfer detail keeps actions in a safe footer', (
    tester,
  ) async {
    await host(tester, width: 390);
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: transferJson(1));
    await tester.pumpAndSettle();
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(
      find.descendant(
        of: find.byWidget(scaffold.bottomNavigationBar!),
        matching: find.text('Edit'),
      ),
      findsOneWidget,
    );
  });
  testWidgets('transfer deletion respects origin route', (tester) async {
    await host(tester);
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: transferJson(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockTransferDetail);
    expect(s.deleteCalls, 0);
    s.failDelete = true;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockTransferDetail);
    expect(
      find.text('Unable to delete stock transfer. Please try again.'),
      findsOneWidget,
    );
    s.failDelete = false;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockTransfer);
    s.records = [transferJson(2)];
    await c.onRefresh();
    await tester.pumpAndSettle();
    c.onDeleteStockTransfer(
      tester.element(find.byType(StockTransferScreen)),
      2,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockTransfer);
  });
  testWidgets('Enter activates transfer row', (tester) async {
    await host(tester, width: 900);
    Focus.of(tester.element(find.text('TR-1'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.stockTransferDetail);
  });
  for (final width in [390.0, 840.0, 1024.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        testWidgets('real shell list detail $width dark=$dark km=$khmer', (
          tester,
        ) async {
          s.records = [
            transferJson(1)
              ..['reference_no'] = 'លេខយោងវែងសម្រាប់ការផ្ទេរស្តុក 1234567890',
          ];
          await c.onRefresh();
          await host(
            tester,
            width: width,
            scale: 2,
            dark: dark,
            khmer: khmer,
            shell: true,
          );
          expect(tester.takeException(), isNull);
          Get.toNamed(
            AppRoutes.stockTransferDetail,
            arguments: s.records.single,
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Rice'),
            200,
            scrollable: find
                .descendant(
                  of: find.byType(StockDetailCardWidget),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(find.text('Rice'), findsOneWidget);
          expect(tester.takeException(), isNull);
          Get.back();
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Add Stock Transfer'.tr),
            -200,
            scrollable: find
                .descendant(
                  of: find.byType(StockTransferScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.tap(find.text('Add Stock Transfer'.tr));
          await tester.pumpAndSettle();
          expect(find.byType(StockTransferFormWidget), findsOneWidget);
          await tester.tap(find.text('Cancel'.tr));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
