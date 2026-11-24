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
  testWidgets('success alone clears cart and opens receipt', (tester) async {
    setUpCustomerTests();
    final sales = SaleTestSaleService();
    final payments = SaleTestPaymentService();
    final ctr = SaleController(service: sales, salePaymentService: payments);
    final product = saleProductJson(1, 'Water')
      ..['warehouse_availability'] = [
        warehouseRow(1, 'Main', 1),
        warehouseRow(2, 'Branch', 4),
      ];
    ctr.addProduct(product, warehouseId: 1);
    for (var i = 0; i < 3; i++) {
      ctr.addProduct(product, warehouseId: 2);
    }
    ctr.changeQuantity(1, 1, 1);
    expect(ctr.cart.length, 2);
    expect(ctr.totalItems, 4);
    ctr.changeQuantity(1, 2, -1);
    expect(ctr.cart[(1, 1)]!['qty'], 1);
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(),
        getPages: [
          GetPage(
            name: '/payment-success',
            page: () => const Scaffold(body: Text('Receipt')),
          ),
        ],
      ),
    );
    final action = ctr.onPayment();
    await tester.pumpAndSettle();
    final duplicate = ctr.onPayment();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await action;
    await duplicate;
    expect(payments.createCalls.single['amount'], 12.5);
    final saleRequest = sales.createCalls.single;
    final paymentRequest = payments.createCalls.single;
    expect(
      saleRequest.keys,
      unorderedEquals([
        'user_id',
        'customer_id',
        'sale_date',
        'status',
        'payment_method',
        'sale_items',
      ]),
    );
    expect(
      paymentRequest.keys,
      unorderedEquals([
        'user_id',
        'sale_id',
        'amount',
        'payment_method',
        'reference_no',
        'payment_date',
        'note',
        'created_at',
      ]),
    );
    expect(saleRequest['user_id'], 5);
    expect(saleRequest['customer_id'], 1);
    expect(saleRequest['status'], 'completed');
    expect(saleRequest['payment_method'], 'Cash');
    expect(DateTime.parse(saleRequest['sale_date']).isUtc, isTrue);
    expect(paymentRequest['payment_date'], saleRequest['sale_date']);
    expect(paymentRequest['created_at'], saleRequest['sale_date']);
    expect(sales.createCalls.single['sale_items'], [
      {'product_id': 1, 'warehouse_id': 1, 'qty': 1},
      {'product_id': 1, 'warehouse_id': 2, 'qty': 2},
    ]);
    expect(ctr.totalItems, 0);
    expect(Get.currentRoute, '/payment-success');
    expect((Get.arguments as Map)['customer'], 'Dara');
    expect((Get.arguments as Map)['total'], 12.5);
    expect(
      (Get.arguments as Map).keys,
      unorderedEquals([
        'customer',
        'payment_method',
        'payment_date',
        'transaction_id',
        'subtotal',
        'total',
        'currency',
      ]),
    );
    expect(
      (Get.arguments as Map)['transaction_id'],
      paymentRequest['reference_no'],
    );
  });
  for (final cleanupFails in [false, true]) {
    testWidgets('failed checkout retains draft cleanup failure=$cleanupFails', (
      tester,
    ) async {
      setUpCustomerTests();
      final sales = SaleTestSaleService()
        ..deleteError = cleanupFails ? Exception('offline') : null;
      final payments = SaleTestPaymentService()
        ..writeError = Exception('offline');
      final ctr = SaleController(service: sales, salePaymentService: payments);
      ctr.addProduct(saleProductJson(1, 'Water'));
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
      await pumpSalesPage(tester, const Scaffold(body: Text('Checkout')));
      final payment = ctr.onPayment();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await payment;
      expect(sales.createCalls.length, 1);
      expect(payments.createCalls.single['amount'], 12.5);
      final saleRequest = sales.createCalls.single;
      final paymentRequest = payments.createCalls.single;
      expect(
        saleRequest.keys,
        unorderedEquals([
          'user_id',
          'customer_id',
          'sale_date',
          'status',
          'payment_method',
          'sale_items',
        ]),
      );
      expect(
        paymentRequest.keys,
        unorderedEquals([
          'user_id',
          'sale_id',
          'amount',
          'payment_method',
          'reference_no',
          'payment_date',
          'note',
          'created_at',
        ]),
      );
      expect(saleRequest['user_id'], 5);
      expect(saleRequest['customer_id'], 1);
      expect(saleRequest['status'], 'completed');
      expect(saleRequest['payment_method'], 'Cash');
      expect(DateTime.parse(saleRequest['sale_date']).isUtc, isTrue);
      expect(paymentRequest['payment_date'], saleRequest['sale_date']);
      expect(paymentRequest['created_at'], saleRequest['sale_date']);
      expect(sales.deleteCalls, [1]);
      expect(ctr.totalItems, 1);
      expect(ctr.selectedCustomer.value?['id'], 1);
      expect(ctr.checkoutBusy, isFalse);
      expect(
        ctr.checkoutError.value,
        cleanupFails
            ? 'The sale may have been created. Check Sales before trying again.'
            : 'Unable to complete payment. Please try again.',
      );
    });
  }
  testWidgets('rapid checkout taps share one confirmation', (tester) async {
    setUpCustomerTests();
    final sales = SaleTestSaleService();
    final payments = SaleTestPaymentService();
    final ctr = SaleController(service: sales, salePaymentService: payments);
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
    expect(payments.createCalls, isEmpty);
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
