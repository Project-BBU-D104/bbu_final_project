import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

/// Refresh loaded stock read models after a committed mutation.
///
/// Prepared lazy bindings are deliberately skipped: readback must not create
/// controllers. Each read settles independently and cannot fail the save.
Future<void> refreshStockReadModels() async {
  Future<void> settle(Future<void> Function() refresh) async {
    try {
      await refresh();
    } catch (_) {
      // Controllers own read errors; the stock mutation has already committed.
    }
  }

  await Future.wait([
    if (Get.isRegistered<WarehouseController>() &&
        !Get.isPrepared<WarehouseController>())
      settle(() => Get.find<WarehouseController>().getWarehouses()),
    if (Get.isRegistered<ProductController>() &&
        !Get.isPrepared<ProductController>())
      settle(
        () => Get.find<ProductController>().getProducts(showLoading: false),
      ),
  ]);
}
