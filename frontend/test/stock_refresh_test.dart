import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/utils/stock_refresh.dart';
import 'package:get/get.dart';

import 'warehouse_stock_test_support.dart';

class _Warehouse extends StockWarehouseController {
  Completer<void>? gate;

  @override
  Future<void> getWarehouses() async {
    getCalls++;
    if (gate != null) await gate!.future;
    if (this.fail) throw StateError('readback failed');
  }
}

class _Product extends StockProductController {
  bool? lastShowLoading;

  @override
  Future<void> getProducts({bool showLoading = true}) async {
    lastShowLoading = showLoading;
    await super.getProducts(showLoading: showLoading);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  tearDown(Get.reset);

  test('missing controllers stay unregistered', () async {
    await refreshStockReadModels();
    expect(Get.isRegistered<WarehouseController>(), isFalse);
    expect(Get.isRegistered<ProductController>(), isFalse);
  });

  test('lazy bindings are never instantiated by readback', () async {
    var creations = 0;
    Get.lazyPut<WarehouseController>(() {
      creations++;
      return _Warehouse();
    });
    Get.lazyPut<ProductController>(() {
      creations++;
      return _Product();
    });
    await refreshStockReadModels();
    expect(creations, 0);
    expect(Get.isPrepared<WarehouseController>(), isTrue);
    expect(Get.isPrepared<ProductController>(), isTrue);
  });

  for (final failWarehouse in [false, true]) {
    test(
      'independent readbacks settle when warehouse failure=$failWarehouse',
      () async {
        final warehouse = _Warehouse()..fail = failWarehouse;
        final product = _Product()..fail = !failWarehouse;
        Get.put<WarehouseController>(warehouse);
        Get.put<ProductController>(product);
        await expectLater(refreshStockReadModels(), completes);
        expect(warehouse.getCalls, 1);
        expect(product.getCalls, 1);
        expect(product.lastShowLoading, isFalse);
      },
    );
  }

  test('one slow readback does not prevent the other from starting', () async {
    final warehouse = _Warehouse()..gate = Completer<void>();
    final product = _Product();
    Get.put<WarehouseController>(warehouse);
    Get.put<ProductController>(product);
    final refreshing = refreshStockReadModels();
    await Future<void>.delayed(Duration.zero);
    expect(product.getCalls, 1);
    warehouse.gate!.complete();
    await refreshing;
  });
}
