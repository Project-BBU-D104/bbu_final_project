import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'profile_widget_test.dart' show FakeStorageService;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/screen/stock/warehouse_stock/warehouse_stock_screen.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'warehouse_stock_test_support.dart';

void main() {
  setUpAll(
    () => locator.registerSingleton<IStorageService>(FakeStorageService()),
  );
  tearDownAll(() => locator.reset());
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  tearDown(() => Get.reset());
  testWidgets('stock list retains rows with retry after refresh failure', (
    tester,
  ) async {
    final s = FakeWarehouseStockService();
    final c = Get.put(WarehouseStockController(service: s));
    await tester.pumpWidget(GetMaterialApp(home: WarehouseStockScreen()));
    await tester.pumpAndSettle();
    s.failRead = true;
    await c.onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Product 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [863.0, 864.0]) {
    testWidgets('stock content switches at $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Get.put(WarehouseStockController(service: FakeWarehouseStockService()));
      // AppPage gutters reduce available content width.
      await tester.pumpWidget(GetMaterialApp(home: WarehouseStockScreen()));
      await tester.pumpAndSettle();
      expect(
        find.byType(AppListCard),
        width == 863 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(AppTable<Map<String, dynamic>>),
        width == 864 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [390.0, 840.0, 1024.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        testWidgets('stock shell layout $width dark=$dark khmer=$khmer', (
          tester,
        ) async {
          final service = FakeWarehouseStockService()
            ..rows = [
              warehouseStockJson(1, qty: 0)
                ..['product'] = null
                ..['warehouse'] = {
                  'name': List.filled(12, 'Long warehouse name').join(' '),
                },
            ];
          Get.put(WarehouseStockController(service: service));
          await pumpWarehouseStockHost(
            tester,
            WarehouseStockScreen(),
            width: width,
            dark: dark,
            khmer: khmer,
            shell: true,
            scale: 2,
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(AppListCard), findsOneWidget);
        });
      }
    }
  }
}
