import 'package:flutter/material.dart';
import 'sale_test_support.dart';
import 'customer_test_support.dart' show setUpCustomerTests;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/services/api_service.dart';
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

class FastCheckoutSales extends SaleTestSaleService {
  final checkoutCalls = <Map<String, dynamic>>[];
  Object? checkoutError;

  @override
  Future<dynamic> createCheckout(Map<String, dynamic> data) async {
    checkoutCalls.add(Map.from(data));
    if (checkoutError != null) throw checkoutError!;
    return {
      'id': 1,
      'subtotal': data['expected_total'],
      'total_amount': data['expected_total'],
    };
  }
}

class QuietCheckoutController extends SaleController {
  QuietCheckoutController(
    FastCheckoutSales sales,
    SaleTestPaymentService payments,
  ) : super(service: sales, salePaymentService: payments);

  @override
  // ignore: must_call_super
  void onInit() => seedSaleCurrency(this);
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    Get.testMode = true;
  });
  tearDown(Get.reset);
  test('loads USD to KHR rate from both currency records', () async {
    final currencies = SaleTestCurrencyService()
      ..rows = [
        {'code': 'USD', 'exchange_rate': '2', 'is_default': true},
        {'code': 'KHR', 'exchange_rate': 8000},
      ];
    final ctr = SaleController(currencyService: currencies);
    ctr.currencies.assignAll(currencies.rows);
    expect(ctr.usdToKhrRate, 4000);

    currencies.rows = [
      {'code': 'USD', 'exchange_rate': 0},
      {'code': 'KHR', 'exchange_rate': 4000},
    ];
    ctr.currencies.assignAll(currencies.rows);
    expect(ctr.usdToKhrRate, isNull);
    currencies.rows = [
      {'code': 'USD', 'exchange_rate': 1},
    ];
    ctr.currencies.assignAll(currencies.rows);
    expect(ctr.usdToKhrRate, isNull);
  });
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
  test(
    'older product responses supply product currency when available',
    () async {
      final sales = SaleTestSaleService()
        ..categories = [
          {
            'id': 1,
            'products': [
              {...saleProductJson(1, 'Water')}
                ..remove('currency_id')
                ..remove('currency'),
              {...saleProductJson(2, 'Books')}
                ..remove('currency_id')
                ..remove('currency'),
            ],
          },
        ];
      final products = SaleTestProductService()
        ..rows = [
          {
            ...saleProductJson(1, 'Water'),
            'currency_id': 7,
            'currency': {'id': 7, 'name': 'Riel', 'symbol': '៛'},
          },
        ];
      final ctr = SaleController(service: sales, productService: products);
      ctr.currency.value = {'id': 8, 'code': 'USD', 'symbol': r'$'};
      ctr.currencies.add({'id': 7, 'code': 'KHR', 'symbol': '៛'});
      await ctr.loadProductCategories();
      final rows = (ctr.categories.single['products'] as List)
          .cast<Map<String, dynamic>>();
      expect(ctr.currencyForProduct(rows.first)?['code'], 'KHR');
      expect(ctr.currencyForProduct(rows.first)?['symbol'], '៛');
      expect(ctr.currencyForProduct(rows.last), isNull);
    },
  );
  testWidgets('success alone clears cart and opens receipt', (tester) async {
    setUpCustomerTests();
    final sales = SaleTestSaleService();
    final payments = SaleTestPaymentService();
    final ctr = SaleController(service: sales, salePaymentService: payments);
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.addProduct(saleProductJson(1, 'Water'));
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
    expect(sales.createCalls, hasLength(1));
    final request = sales.createCalls.single;
    expect(request['user_id'], 5);
    expect(request['customer_id'], 1);
    expect(request['sale_items'], [
      {'product_id': 1, 'qty': 2},
    ]);
    expect(request['expected_currency_id'], 1);
    expect(request['expected_total'], '10.00');
    expect(payments.createCalls, isEmpty);
    expect(ctr.totalItems, 0);
    expect(Get.currentRoute, '/payment-success');
    expect((Get.arguments as Map)['customer'], 'Dara');
    expect((Get.arguments as Map)['total'], 10.0);
    expect((Get.arguments as Map)['transaction_id'], request['reference_no']);
  });
  testWidgets('checkout records sale and payment in one request', (
    tester,
  ) async {
    setUpCustomerTests();
    final sales = FastCheckoutSales();
    final payments = SaleTestPaymentService();
    final ctr = Get.put<SaleController>(
      QuietCheckoutController(sales, payments),
    );
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    ctr.paymentTypes.add(ctr.selectedPaymentType.value!);
    await pumpSalesPage(
      tester,
      CurrentSaleWidget(),
      getPages: [
        GetPage(name: '/payment-success', page: () => const Scaffold()),
      ],
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Payment'));
    await tester.tap(find.widgetWithText(FilledButton, 'Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(sales.checkoutCalls, hasLength(1));
    expect(sales.checkoutCalls.single['reference_no'], startsWith('SALE-'));
    expect(sales.createCalls, isEmpty);
    expect(payments.createCalls, isEmpty);
    expect(ctr.cart, isEmpty);
    expect(Get.currentRoute, '/payment-success');
  });
  testWidgets('uncertain checkout does not retry or delete the sale', (
    tester,
  ) async {
    setUpCustomerTests();
    final sales = FastCheckoutSales()..checkoutError = Exception('offline');
    final ctr = SaleController(service: sales);
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await pumpSalesPage(tester, const Scaffold());
    final action = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await action;
    expect(sales.checkoutCalls, hasLength(1));
    expect(sales.createCalls, isEmpty);
    expect(sales.deleteCalls, isEmpty);
    expect(ctr.cart, hasLength(1));
    expect(ctr.checkoutError.value, contains('Check Sales'));
  });
  testWidgets('checkout rejection is not mistaken for an older backend', (
    tester,
  ) async {
    setUpCustomerTests();
    final sales = FastCheckoutSales()
      ..checkoutError = ApiException(404, 'Product(s) [1] not found');
    final ctr = SaleController(service: sales);
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await pumpSalesPage(tester, const Scaffold());
    final action = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await action;
    expect(sales.checkoutCalls, hasLength(1));
    expect(sales.createCalls, isEmpty);
    expect(sales.deleteCalls, isEmpty);
    expect(ctr.cart, hasLength(1));
    expect(
      ctr.checkoutError.value,
      'Unable to complete payment. Please try again.',
    );
  });
  testWidgets('rejected atomic checkout keeps the draft', (tester) async {
    setUpCustomerTests();
    final sales = SaleTestSaleService()
      ..createError = ApiException(400, 'Rejected');
    final payments = SaleTestPaymentService();
    final ctr = SaleController(service: sales, salePaymentService: payments);
    seedSaleCurrency(ctr);
    ctr.addProduct(saleProductJson(1, 'Water'));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await pumpSalesPage(tester, const Scaffold(body: Text('Checkout')));
    final payment = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await payment;
    expect(sales.createCalls, hasLength(1));
    expect(payments.createCalls, isEmpty);
    expect(sales.deleteCalls, isEmpty);
    expect(ctr.totalItems, 1);
    expect(ctr.checkoutBusy, isFalse);
    expect(
      ctr.checkoutError.value,
      'Unable to complete payment. Please try again.',
    );
  });
  testWidgets('rapid checkout taps share one confirmation', (tester) async {
    setUpCustomerTests();
    final sales = SaleTestSaleService();
    final payments = SaleTestPaymentService();
    final ctr = SaleController(service: sales, salePaymentService: payments);
    seedSaleCurrency(ctr);
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
    ctr.addProduct({'id': 1, 'sale_price': '5'});
    ctr.addProduct({'id': 1, 'sale_price': '5'});
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
  test('confirmation busy freezes cart mutations', () {
    final ctr = SaleController();
    ctr.addProduct({'id': 1, 'sale_price': '5'});
    ctr.isConfirmingPayment.value = true;
    ctr.addProduct({'id': 1, 'sale_price': '5'});
    ctr.changeQuantity(1, -1);
    expect(ctr.totalItems, 1);
    expect(ctr.checkoutBusy, isTrue);
    expect(ctr.canCheckout, isFalse);
  });
}
