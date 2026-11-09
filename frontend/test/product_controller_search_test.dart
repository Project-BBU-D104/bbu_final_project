import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:get/get.dart';

class _FakeProductService implements ProductService {
  _FakeProductService(this.items);

  List<Map<String, dynamic>> items;
  int getCalls = 0;

  @override
  Future<dynamic> getProducts() async {
    getCalls++;
    return items;
  }

  @override
  Future<dynamic> getProductById(int id) async =>
      items.firstWhere((item) => item['id'] == id);

  @override
  Future<dynamic> createProduct(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateProduct(int id, Map<String, dynamic> data) async =>
      data;

  @override
  Future<dynamic> deleteProduct(int id) async => true;
}

List<Map<String, dynamic>> composedFixture() => <Map<String, dynamic>>[
  {'id': 1, 'name': 'Water', 'barcode': '111', 'category': {'name': 'Drinks'}},
  {'id': 2, 'name': 'Bread', 'barcode': '222', 'category': {'name': 'Bakery'}},
  {
    'id': 3,
    'name': 'Bread roll',
    'barcode': '333',
    'category': {'name': 'Drinks'},
  },
];

/// Loads a controller from the fake service, which also seeds the static
/// product cache so each test is independent of prior cache contents.
Future<ProductController> seeded(_FakeProductService service) async {
  final controller = ProductController(service: service);
  await controller.getProducts(showLoading: false);
  return controller;
}

void main() {
  tearDown(Get.reset);

  final items = <Map<String, dynamic>>[
    {'id': 1, 'name': 'Water', 'barcode': '111'},
    {'id': 2, 'name': 'Bread', 'barcode': '222'},
  ];

  test(
    'clearing a search restores every product loaded from the cache',
    () async {
      final service = _FakeProductService(items);

      // Seed the static cache the same way the app does on first load.
      final first = ProductController(service: service);
      await first.getProducts();

      // A controller created within the cache window takes the cached path.
      final controller = ProductController(service: service);
      controller.onInit();

      controller.searchProduct('bread');
      expect(controller.searchProductList.length, 1);

      controller.searchProduct('');

      expect(controller.searchProductList.length, items.length);
      expect(controller.products.length, items.length);
    },
  );

  test(
    'reloading products keeps every product when data came from the cache',
    () async {
      final service = _FakeProductService(items);

      final first = ProductController(service: service);
      await first.getProducts();

      final controller = ProductController(service: service);
      controller.onInit();

      await controller.getProducts();

      expect(controller.products.length, items.length);
      expect(controller.searchProductList.length, items.length);
    },
  );

  test('an empty cached list does not stop a fresh fetch', () async {
    final service = _FakeProductService([]);

    // Cache an empty result the way a first load against an empty server would.
    final first = ProductController(service: service);
    await first.getProducts();
    expect(service.getCalls, 1);

    service.items = items;

    final controller = ProductController(service: service);
    controller.onInit();

    // The empty cache must not be treated as fresh data, so onInit fetches.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.getCalls, greaterThan(1));
    expect(controller.products.length, items.length);
    expect(controller.loadError.value, isEmpty);
  });

  test('query and category return their intersection', () async {
    final service = _FakeProductService(composedFixture());
    final controller = await seeded(service);

    // Barcode queries match through the existing BarcodeUtils behavior.
    controller.searchProduct('111');
    expect(controller.filteredItems.map((p) => p['id']), [1]);

    controller.filterCategory.value = 'Drinks';
    controller.searchProduct('bread');
    expect(controller.filteredItems.map((p) => p['id']), [3]);
  });

  test('clearing query keeps category', () async {
    final service = _FakeProductService(composedFixture());
    final controller = await seeded(service);

    controller.filterCategory.value = 'Drinks';
    controller.searchProduct('bread');
    expect(controller.filteredItems.map((p) => p['id']), [3]);
    controller.searchProduct('');
    expect(controller.filteredItems.map((p) => p['id']), [1, 3]);
  });

  test('refresh preserves combined filtering', () async {
    final service = _FakeProductService(composedFixture());
    final controller = await seeded(service);

    controller.filterCategory.value = 'Drinks';
    controller.searchProduct('bread');

    service.items = <Map<String, dynamic>>[
      {
        'id': 4,
        'name': 'Bread loaf',
        'barcode': '444',
        'category': {'name': 'Drinks'},
      },
      {
        'id': 5,
        'name': 'Milk',
        'barcode': '555',
        'category': {'name': 'Drinks'},
      },
    ];
    await controller.getProducts(showLoading: false);

    expect(controller.filteredItems.map((p) => p['id']), [4]);
  });

  test('clearFilters preserves search and form selections', () async {
    final service = _FakeProductService(composedFixture());
    final controller = await seeded(service);

    controller.selectedCategory.value = '7';
    controller.searchProduct('bread');

    controller.clearFilters();

    expect(controller.searchQuery.value, 'bread');
    expect(controller.selectedCategory.value, '7');
    expect(controller.filterCategory.value, 'All');
    expect(controller.selectedStatus.value, 'All');
    expect(controller.selectedRecency.value, 'All');
  });
}
