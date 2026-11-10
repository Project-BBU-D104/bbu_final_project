import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:get/get.dart';

// Lookup controllers whose onInit does not fetch; tests seed their Rx lists.
class SeededCategoryController extends CategoryController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class SeededUnitController extends UnitController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class SeededCurrencyController extends CurrencyController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class SeededWarehouseController extends WarehouseController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void seedProductLookups({bool empty = false}) {
  Get.put<CategoryController>(
    SeededCategoryController(),
  ).categoryList.assignAll(
    empty
        ? []
        : [
            {'id': 1, 'name': 'Drinks'},
            {'id': 2, 'name': 'Bakery'},
          ],
  );
  Get.put<UnitController>(SeededUnitController()).unitList.assignAll(
    empty
        ? []
        : [
            {'id': 1, 'name': 'Piece', 'short_name': 'Pcs'},
          ],
  );
  Get.put<CurrencyController>(
    SeededCurrencyController(),
  ).currencyList.assignAll(
    empty
        ? []
        : [
            {'id': 1, 'name': 'US Dollar', 'symbol': r'$', 'code': 'USD'},
          ],
  );
  Get.put<WarehouseController>(
    SeededWarehouseController(),
  ).warehouseList.assignAll(
    empty
        ? []
        : [
            {'id': 1, 'name': 'Main'},
          ],
  );
}

/// Shared product map used by the redesign test suites. Mutate the returned
/// map to build scenarios (missing dates, null currency, ...).
Map<String, dynamic> productFixture(
  int id,
  String name, {
  String category = 'Drinks',
}) => <String, dynamic>{
  'id': id,
  'name': name,
  'barcode': '${id * 111}',
  'cost_price': (id * 0.75).toStringAsFixed(2),
  'sale_price': (id * 1.5).toStringAsFixed(2),
  'stock_qty': id * 2,
  'currency': {'id': 1, 'symbol': r'$', 'code': 'USD', 'name': 'US Dollar'},
  'category': {'id': 1, 'name': category},
  'unit': {'id': 1, 'name': 'Pcs'},
  'warehouse': null,
  'photo': null,
  'created_at': '2025-01-0${id}T08:00:00',
  'description': '$name description',
};

/// Records call counts and the last create/update payload so form tests can
/// assert what reached the service. Scenario-specific delayed/error services
/// subclass this in their own test files.
class FakeProductService implements ProductService {
  FakeProductService(this.items);

  List<Map<String, dynamic>> items;
  int getCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;

  @override
  Future<dynamic> getProducts() async {
    getCalls++;
    return items;
  }

  @override
  Future<dynamic> getProductById(int id) async =>
      items.firstWhere((item) => item['id'] == id);

  @override
  Future<dynamic> createProduct(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    return data;
  }

  @override
  Future<dynamic> updateProduct(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    return {'id': id, ...data};
  }

  @override
  Future<dynamic> deleteProduct(int id) async => true;
}
