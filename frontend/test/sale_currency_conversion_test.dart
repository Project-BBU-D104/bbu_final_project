import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/current_sale_screen.dart';
import 'package:frontend/screen/sale/sale_screen/sale_screen.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/main_service/system_configuration_service.dart';
import 'package:frontend/utils/sale_currency_calculator.dart';
import 'package:get/get.dart';

import 'customer_test_support.dart' show setUpCustomerTests;
import 'profile_widget_test.dart' show FakeStorageService;
import 'sale_test_support.dart';

class ConfiguredStorage extends FakeStorageService {
  ConfiguredStorage() {
    (stored['user'] as Map)['system_configuration_id'] = 9;
  }
}

class FakeConfiguration extends SystemConfigurationService {
  int? requestedId;
  @override
  Future<dynamic> getSystemConfigurationById(int id) async {
    requestedId = id;
    return {
      'id': id,
      'default_currency': {'id': 2, 'symbol': '៛'},
    };
  }
}

class ConvertedCheckoutService extends SaleTestSaleService {
  final calls = <Map<String, dynamic>>[];
  Object? error;
  @override
  Future<dynamic> createCheckout(Map<String, dynamic> data) async {
    calls.add(Map.from(data));
    if (error != null) throw error!;
    return {
      'id': 1,
      'subtotal': '52030',
      'total_amount': '52030',
      'currency_code': 'KHR',
      'currency_symbol': '៛',
    };
  }
}

class QuietCurrencyController extends SaleController {
  QuietCurrencyController({
    required SaleTestCurrencyService rates,
    required FakeConfiguration config,
    required ConfiguredStorage storage,
    required ConvertedCheckoutService sales,
  }) : super(
         currencyService: rates,
         configurationService: config,
         storageService: storage,
         service: sales,
         productService: SaleTestProductService(),
       );
  @override
  // ignore: must_call_super
  void onInit() {}
}

Map<String, dynamic> product(
  int id,
  String name,
  String price,
  int currencyId,
) => {
  ...saleProductJson(id, name),
  'sale_price': price,
  'currency_id': currencyId,
};

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  test('exact conversion rounds per line and rejects invalid rates', () {
    final usd = {'id': 1, 'code': 'USD', 'exchange_rate': 1};
    final khr = {'id': 2, 'code': 'KHR', 'exchange_rate': 4000};
    expect(
      SaleCurrencyCalculator.convertedLineMinor(
        price: '6',
        quantity: 1,
        source: usd,
        target: khr,
      ),
      BigInt.from(24000),
    );
    expect(
      SaleCurrencyCalculator.convertedLineMinor(
        price: '100',
        quantity: 2,
        source: khr,
        target: usd,
      ),
      BigInt.from(5),
    );
    expect(
      SaleCurrencyCalculator.convertedLineMinor(
        price: '1',
        quantity: 1,
        source: khr,
        target: usd,
      ),
      isNull,
    );
    expect(
      SaleCurrencyCalculator.convertedLineMinor(
        price: '6',
        quantity: 1,
        source: {...usd, 'exchange_rate': 0},
        target: khr,
      ),
      isNull,
    );
  });

  testWidgets(
    'mixed-currency cart uses system currency for display and payment',
    (tester) async {
      final config = FakeConfiguration();
      final rates = SaleTestCurrencyService()
        ..rows = [
          {
            'id': 1,
            'code': 'USD',
            'symbol': r'$',
            'exchange_rate': 1,
            'is_default': true,
          },
          {
            'id': 2,
            'code': 'KHR',
            'symbol': '៛',
            'exchange_rate': 4000,
            'is_default': false,
          },
        ];
      final sales = ConvertedCheckoutService();
      final ctr = Get.put<SaleController>(
        QuietCurrencyController(
          rates: rates,
          config: config,
          storage: ConfiguredStorage(),
          sales: sales,
        ),
      );
      await ctr.loadCurrency();
      expect(config.requestedId, 9);
      expect(ctr.currency.value?['code'], 'KHR');
      final kuromi = product(1, 'Kuromi', '6', 1);
      final books = product(2, 'Books', '1', 1);
      final motorcycle = product(3, 'Motorcycle', '30', 2);
      ctr.categories.add({
        'name': 'Products',
        'products': [kuromi, books, motorcycle],
      });
      ctr.addProduct(kuromi);
      ctr.addProduct(kuromi);
      ctr.addProduct(books);
      ctr.addProduct(motorcycle);
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      ctr.selectedPaymentType.value = ctr.paymentTypes.first;
      expect(ctr.confirmedSubtotal, '52030');
      await pumpSalesPage(
        tester,
        SaleScreen(),
        size: const Size(390, 844),
        getPages: [
          GetPage(name: '/current-sale', page: () => CurrentSaleWidget()),
          GetPage(
            name: '/payment-success',
            page: () => const Scaffold(body: Text('Receipt')),
          ),
        ],
      );
      expect(find.text('Amount: ៛52,030'), findsOneWidget);
      await tester.tap(find.byType(PaymentFooterWidget));
      await tester.pumpAndSettle();
      expect(find.text('៛52,030'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Payment'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('៛52,030'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(sales.calls.single['expected_total'], '52030');
      expect(sales.calls.single['expected_currency_id'], 2);
      expect(Get.currentRoute, '/payment-success');
      expect((Get.arguments as Map)['total'], 52030);
    },
  );

  test('unknown currency or invalid exchange rate prevents checkout', () async {
    final rates = SaleTestCurrencyService()
      ..rows = [
        {'id': 1, 'code': 'USD', 'symbol': r'$', 'exchange_rate': 0},
        {'id': 2, 'code': 'KHR', 'symbol': '៛', 'exchange_rate': 4000},
      ];
    final ctr = QuietCurrencyController(
      rates: rates,
      config: FakeConfiguration(),
      storage: ConfiguredStorage(),
      sales: ConvertedCheckoutService(),
    );
    await ctr.loadCurrency();
    ctr.addProduct(product(1, 'Water', '6', 1));
    ctr.selectedCustomer.value = {'id': 1};
    ctr.selectedPaymentType.value = {'id': 1};
    expect(ctr.subtotal, isNull);
    expect(ctr.canCheckout, isFalse);
  });

  testWidgets(
    'changed exchange rate blocks payment until prices are reloaded',
    (tester) async {
      final rates = SaleTestCurrencyService()
        ..rows = [
          {'id': 1, 'code': 'USD', 'symbol': r'$', 'exchange_rate': 1},
          {'id': 2, 'code': 'KHR', 'symbol': '៛', 'exchange_rate': 4000},
        ];
      final water = product(1, 'Water', '6', 1);
      final sales = ConvertedCheckoutService()
        ..error = ApiException(409, 'Prices changed')
        ..categories = [
          {
            'name': 'Products',
            'products': [water],
          },
        ];
      final ctr = Get.put<SaleController>(
        QuietCurrencyController(
          rates: rates,
          config: FakeConfiguration(),
          storage: ConfiguredStorage(),
          sales: sales,
        ),
      );
      await ctr.loadCurrency();
      ctr.addProduct(water);
      ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
      ctr.paymentTypes.add({'id': 1, 'name': 'Cash'});
      ctr.selectedPaymentType.value = ctr.paymentTypes.first;
      await pumpSalesPage(tester, CurrentSaleWidget());
      await tester.tap(find.widgetWithText(FilledButton, 'Payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(sales.calls.single['expected_total'], '24000');
      expect(ctr.needsPriceRefresh.value, isTrue);
      expect(ctr.canCheckout, isFalse);
      expect(ctr.cart, hasLength(1));
      rates.rows[1]['exchange_rate'] = 4100;
      await ctr.refreshSalePrices();
      await tester.pumpAndSettle();
      expect(ctr.confirmedSubtotal, '24600');
      expect(ctr.needsPriceRefresh.value, isFalse);
      expect(ctr.canCheckout, isTrue);
    },
  );

  testWidgets('old server never falls back to an unconverted checkout', (
    tester,
  ) async {
    final rates = SaleTestCurrencyService()
      ..rows = [
        {'id': 1, 'code': 'USD', 'symbol': r'$', 'exchange_rate': 1},
        {'id': 2, 'code': 'KHR', 'symbol': '៛', 'exchange_rate': 4000},
      ];
    final sales = ConvertedCheckoutService()
      ..error = ApiException(404, 'Not Found');
    final ctr = QuietCurrencyController(
      rates: rates,
      config: FakeConfiguration(),
      storage: ConfiguredStorage(),
      sales: sales,
    );
    await ctr.loadCurrency();
    ctr.addProduct(product(1, 'Water', '6', 1));
    ctr.selectedCustomer.value = {'id': 1, 'name': 'Dara'};
    ctr.selectedPaymentType.value = {'id': 1, 'name': 'Cash'};
    await pumpSalesPage(tester, const Scaffold());
    final payment = ctr.onPayment();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await payment;
    expect(sales.calls, hasLength(1));
    expect(sales.createCalls, isEmpty);
    expect(ctr.cart, hasLength(1));
    expect(ctr.checkoutError.value, contains('server must be updated'));
  });
}
