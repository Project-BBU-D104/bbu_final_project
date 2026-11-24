import 'package:frontend/global.dart' show storage;
import 'package:frontend/services/api_service.dart';
import 'profile_widget_test.dart' show FakeStorageService;
import 'package:flutter/material.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:get/get.dart';

class Categories extends SaleService {
  dynamic response = <Map<String, dynamic>>[];
  bool fail = false;
  @override
  Future<dynamic> getProductCategories() async {
    if (fail) throw Exception('offline');
    return response;
  }
}

class Products extends ProductService {
  @override
  Future<dynamic> getProducts() async => throw Exception('optional');
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    Get.testMode = true;
  });
  tearDown(Get.reset);
  test(
    'reloaded method and customer selections use current map instances',
    () async {
      final customers = SaleTestCustomerService()
        ..rows = [
          {'id': 1, 'name': 'Old'},
        ];
      final methods = SaleTestPaymentTypeService()
        ..rows = [
          {'id': 1, 'name': 'Cash', 'status': true},
        ];
      final ctr = SaleController(
        customerService: customers,
        paymentTypeService: methods,
      );
      await ctr.loadCustomers();
      await ctr.loadPaymentTypes();
      customers.rows = [
        {'id': 1, 'name': 'New'},
      ];
      methods.rows = [
        {'id': 1, 'name': 'New cash', 'status': true},
      ];
      await ctr.loadCustomers();
      await ctr.loadPaymentTypes();
      expect(
        identical(ctr.selectedCustomer.value, customers.rows.first),
        isTrue,
      );
      expect(
        identical(ctr.selectedPaymentType.value, methods.rows.first),
        isTrue,
      );
      customers.rows = [];
      methods.rows = [
        {'id': 2, 'status': false},
      ];
      await ctr.loadCustomers();
      await ctr.loadPaymentTypes();
      expect(ctr.selectedCustomer.value, isNull);
      expect(ctr.selectedPaymentType.value, isNull);
    },
  );
  test('optional barcode enrichment failure still shows products', () async {
    final sales = SaleTestSaleService()
      ..categories = [
        {
          'id': 1,
          'products': [saleProductJson(1, 'Water')],
        },
      ];
    final products = SaleTestProductService()..readError = Exception('offline');
    final ctr = SaleController(service: sales, productService: products);
    await ctr.loadProductCategories();
    expect(ctr.productLoadError.value, isEmpty);
    expect(ctr.categories.length, 1);
    products.readError = null;
    products.rows = [
      {...saleProductJson(1, 'Water'), 'barcode': '99999'},
    ];
    await ctr.loadProductCategories();
    ctr.searchCtr.keyword.value = '99999';
    expect(ctr.filteredCategories.single['products'], hasLength(1));
    sales.readError = null;
    sales.categories = [];
    await ctr.loadProductCategories();
    expect(ctr.categories, isEmpty);
  });
  for (final failure in [
    'timeout',
    'malformed',
    'server',
    'cleanup',
    'save',
    'shortage',
    'conflict',
    'endpoint',
  ]) {
    testWidgets('confirmed checkout recovers from $failure', (tester) async {
      setUpCustomerTests();
      final local = storage as FakeStorageService;
      local.values.clear();
      final sales = SaleTestSaleService();
      final product = saleProductJson(1, 'Water');
      sales.categories = [
        {
          'products': [product],
        },
      ];
      final ctr = SaleController(
        service: sales,
        productService: SaleTestProductService(),
      );
      ctr.addProduct(product);
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
      await pumpSalesPage(
        tester,
        const Scaffold(),
        getPages: [
          GetPage(
            name: '/payment-success',
            page: () => const Scaffold(body: Text('Receipt')),
          ),
        ],
      );
      sales.loseResponse = failure == 'timeout';
      sales.malformed = failure == 'malformed' ? {} : null;
      sales.createError = switch (failure) {
        'server' => ApiException(503, 'Service unavailable'),
        'shortage' => ApiException(400, 'Only 0 left'),
        'conflict' => ApiException(409, 'Checkout ID conflict'),
        'endpoint' => ApiException(404, 'Not found'),
        _ => null,
      };
      local.failSave = failure == 'save';
      local.failCleanup = failure == 'cleanup';
      final action = ctr.onPayment();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await action;
      local.failSave = local.failCleanup = false;
      expect(sales.createCalls, isEmpty);
      expect(sales.deleteCalls, isEmpty);
      if (failure == 'save') {
        expect(sales.requests, isEmpty);
        expect(ctr.totalItems, 1);
        return;
      }
      final first = sales.requests.single;
      expect(first['checkout_id'], matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(first['expected_total'], '5.00');
      if (failure == 'shortage' || failure == 'endpoint') {
        expect(
          ctr.checkoutError.value,
          contains(failure == 'shortage' ? 'Only 0 left' : 'upgrade'),
        );
        expect(ctr.hasPendingCheckout, failure == 'endpoint');
        expect(ctr.totalItems, 1);
        return;
      }
      if (failure == 'conflict') {
        expect(ctr.checkoutConflict.value, isTrue);
        await ctr.dismissConflict();
        expect(ctr.hasPendingCheckout, isFalse);
        expect(sales.requests, hasLength(1));
        return;
      }
      expect(ctr.hasPendingCheckout, isTrue);
      final user = local.stored['user']['id'];
      local.stored['user']['id'] = 88;
      final other = SaleController(service: sales);
      other.restorePendingCheckout();
      expect(other.hasPendingCheckout, isFalse);
      local.stored['user']['id'] = user;
      final resumed = SaleController(
        service: sales,
        productService: SaleTestProductService(),
      );
      resumed.restorePendingCheckout();
      expect(resumed.totalItems, 0);
      sales.categories = [];
      sales.malformed = null;
      sales.createError = null;
      await resumed.onPayment();
      await tester.pumpAndSettle();
      expect(sales.requests[1], equals(first));
      expect(find.text('Receipt'), findsOneWidget);
      expect(Get.arguments['invoice_no'], 'POS-42');
      expect(sales.receipts, hasLength(1));
      expect(resumed.hasPendingCheckout, isFalse);
      sales.categories = [
        {
          'products': [product],
        },
      ];
      await resumed.loadProductCategories();
      resumed.addProduct(product);
      resumed.selectedCustomer.value = {'id': 1};
      resumed.selectedPaymentType.value = {'id': 1};
      final another = resumed.onPayment();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await another;
      expect(sales.requests.last['checkout_id'], isNot(first['checkout_id']));
    });
  }
  testWidgets('rapid checkout taps share one confirmation', (tester) async {
    setUpCustomerTests();
    (storage as FakeStorageService).values.clear();
    final sales = SaleTestSaleService();
    final ctr = SaleController(service: sales);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await pumpSalesPage(tester, const Scaffold(body: Text('Checkout')));
    final first = ctr.onPayment();
    final second = ctr.onPayment();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(ctr.checkoutBusy, isTrue);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await Future.wait([first, second]);
    expect(sales.createCalls, isEmpty);
    expect(sales.requests, isEmpty);
    expect(ctr.checkoutBusy, isFalse);
  });
  test('category load failure retains cart and query', () async {
    final service = Categories();
    final ctr = SaleController(service: service, productService: Products());
    ctr.categories.add({'id': 1, 'products': []});
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.searchCtr.keyword.value = 'water';
    service.fail = true;
    await ctr.loadProductCategories();
    expect(ctr.productLoadError.value, isNotEmpty);
    expect(ctr.categories.single['id'], 1);
    expect(ctr.totalItems, 2);
    expect(ctr.searchCtr.keyword.value, 'water');
    service.fail = false;
    service.response = [
      {'id': 2, 'products': []},
    ];
    await ctr.loadProductCategories();
    expect(ctr.productLoadError.value, isEmpty);
    expect(ctr.categories.single['id'], 2);
  });
  test(
    'catalog refresh updates each cart limit and preserves requested quantities',
    () async {
      final service = Categories();
      final ctr = SaleController(service: service, productService: Products());
      final product = saleProductJson(1, 'Water');
      ctr.addProduct(product);
      ctr.addProduct(product);
      service.response = [
        {
          'products': [
            {
              ...product,
              'warehouse_availability': [warehouseRow(1, 'Main', 1)],
            },
          ],
        },
      ];
      await ctr.loadProductCategories();
      ctr.selectedCustomer.value = {'id': 1};
      ctr.selectedPaymentType.value = {'id': 1};
      expect(ctr.canCheckout, isFalse);
      ctr.addProduct(product); // Stale picker row from before the refresh.
      ctr.changeQuantity(1, 1, 1);
      expect(ctr.totalItems, 2);
      ctr.changeQuantity(1, 1, -1);
      expect(ctr.totalItems, 1);
      expect(ctr.canCheckout, isTrue);
      service.response = [];
      await ctr.loadProductCategories();
      ctr.changeQuantity(1, 1, 1);
      expect(ctr.totalItems, 1);
      expect(ctr.cart.values.single['available_qty'], 0);
    },
  );
  test('confirmation busy freezes cart mutations', () {
    final ctr = SaleController();
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.isConfirmingPayment.value = true;
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.changeQuantity(1, 1, -1);
    expect(ctr.totalItems, 1);
    expect(ctr.checkoutBusy, isTrue);
    expect(ctr.canCheckout, isFalse);
  });
}
