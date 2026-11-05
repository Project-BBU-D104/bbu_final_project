import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/product/product_screen.dart';
import 'package:frontend/screen/product/widget/product_card_detail_widget.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:get/get.dart';

class _FakeProductService implements ProductService {
  _FakeProductService(this.items);

  List<Map<String, dynamic>> items;

  @override
  Future<dynamic> getProducts() async => items;

  @override
  Future<dynamic> getProductById(int id) async =>
      items.firstWhere((item) => item['id'] == id);

  @override
  Future<dynamic> createProduct(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateProduct(int id, Map<String, dynamic> data) async =>
      data;

  @override
  Future<dynamic> deleteProduct(int id) async {
    items = items.where((item) => item['id'] != id).toList();
    return {'message': 'ok'};
  }
}

Map<String, dynamic> _product(
  int id,
  String name, {
  String category = 'Drinks',
}) => {
  'id': id,
  'name': name,
  'barcode': 'barcode-$id',
  'photo': '',
  'sale_price': '1.00',
  'created_at': DateTime.now().toIso8601String(),
  'category': {'id': category.hashCode, 'name': category},
  'unit': {'id': 1, 'name': 'Piece'},
  'currency': {'id': 1, 'name': 'USD', 'symbol': r'$', 'code': 'USD'},
};

Future<void> _pumpProductApp(
  WidgetTester tester,
  ProductController controller,
) async {
  Get.lazyPut<ProductController>(() => controller);

  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/product',
      getPages: [
        GetPage(name: '/product', page: () => ProductScreen()),
        GetPage(
          name: '/product-card-detail',
          page: () => ProductCardDetailWidget(),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _deleteFirstProduct(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Ok'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  });

  tearDown(Get.reset);

  testWidgets('deleting a product keeps the other products visible', (
    tester,
  ) async {
    final service = _FakeProductService([
      _product(1, 'Water'),
      _product(2, 'Bread'),
    ]);

    await _pumpProductApp(tester, ProductController(service: service));

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);

    await _deleteFirstProduct(tester, 'Water');

    expect(find.text('No products available'), findsNothing);
    expect(find.text('Bread'), findsOneWidget);
  });

  testWidgets('deleting the last product in the active filter keeps others', (
    tester,
  ) async {
    final service = _FakeProductService([
      _product(1, 'Water'),
      _product(2, 'Bread', category: 'Bakery'),
    ]);

    final controller = ProductController(service: service);
    controller.filterCategory.value = 'Drinks';

    await _pumpProductApp(tester, controller);

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Bread'), findsNothing);

    await _deleteFirstProduct(tester, 'Water');

    // Water was the only Drinks product, but Bread still exists. The stale
    // filter must not hide every remaining product.
    expect(find.text('No products available'), findsNothing);
    expect(find.text('Bread'), findsOneWidget);
  });

  testWidgets('an empty filter result offers to clear the filter', (
    tester,
  ) async {
    final service = _FakeProductService([
      _product(1, 'Water'),
      _product(2, 'Bread', category: 'Bakery'),
    ]);

    final controller = ProductController(service: service);
    controller.filterCategory.value = 'Empty';

    await _pumpProductApp(tester, controller);

    expect(find.text('No products match the selected filter'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);
  });
}
