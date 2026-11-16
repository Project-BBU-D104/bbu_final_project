import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/stock_adjustment/stock_adjustment_screen.dart';
import 'package:frontend/screen/stock/stock_transfer/stock_transfer_screen.dart';
import 'package:frontend/screen/stock/warehouse/warehouse_screen.dart';
import 'package:frontend/screen/stock/warehouse_stock/warehouse_stock_screen.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';

import 'stock_adjustment_test_support.dart';
import 'stock_transfer_test_support.dart';
import 'supplier_test_support.dart';
import 'warehouse_stock_test_support.dart';
import 'warehouse_test_support.dart';

void main() {
  setUp(() {
    setUpSupplierTests();
    Get.put(WarehouseController(service: FakeWarehouseService()));
    Get.put(WarehouseStockController(service: FakeWarehouseStockService()));
    Get.put(
      StockAdjustmentController(
        service: FakeStockAdjustmentService(),
        warehouseStockService: FakeAdjustmentStockService(),
      ),
    );
    Get.put(
      ProductTransferController(
        service: FakeProductTransferService(),
        warehouseStockService: FakeTransferStockService(),
      ),
    );
  });
  tearDown(Get.reset);

  final screens = <String, Widget Function()>{
    AppRoutes.warehouse: WarehouseScreen.new,
    AppRoutes.warehouseStock: WarehouseStockScreen.new,
    AppRoutes.stockAdjustment: StockAdjustmentScreen.new,
    AppRoutes.stockTransfer: StockTransferScreen.new,
  };

  for (final entry in screens.entries) {
    for (final width in [390.0, 840.0, 1440.0]) {
      for (final dark in [false, true]) {
        for (final locale in [
          const Locale('en', 'US'),
          const Locale('km', 'KH'),
        ]) {
          testWidgets(
            '${entry.key} has one working Back action at $width dark=$dark ${locale.languageCode}',
            (tester) async {
              tester.view.physicalSize = Size(width, 1000);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(() async {
                await tester.pumpWidget(const SizedBox.shrink());
                await tester.pumpAndSettle();
              });
              await tester.pumpWidget(
                GetMaterialApp(
                  translations: AppTranslation(),
                  locale: locale,
                  theme: dark ? AppTheme.dark() : AppTheme.light(),
                  defaultTransition: Transition.noTransition,
                  initialRoute: '/origin',
                  getPages: [
                    GetPage(
                      name: '/origin',
                      page: () => const Scaffold(body: Text('origin')),
                    ),
                    GetPage(name: entry.key, page: entry.value),
                  ],
                  builder: (context, navigator) =>
                      DesktopAppShell(route: entry.key, child: navigator!),
                ),
              );
              await tester.pumpAndSettle();
              Get.toNamed(entry.key);
              await tester.pumpAndSettle();

              final back = find.byTooltip('Back'.tr);
              expect(back, findsOneWidget);
              await tester.tap(back);
              await tester.pumpAndSettle();
              expect(Get.currentRoute, '/origin');
              expect(find.text('origin'), findsOneWidget);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
