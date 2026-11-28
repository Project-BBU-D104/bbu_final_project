import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/barcode_utils.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SaleController extends GetxController {
  SaleController({
    SaleService? service,
    ProductService? productService,
    CustomerService? customerService,
    CurrencyService? currencyService,
    PaymentTypeService? paymentTypeService,
    SalePaymentService? salePaymentService,
    IStorageService? storageService,
  }) : service = service ?? SaleService(),
       productService = productService ?? ProductService(),
       customerService = customerService ?? CustomerService(),
       currencyService = currencyService ?? CurrencyService(),
       paymentTypeService = paymentTypeService ?? PaymentTypeService(),
       salePaymentService = salePaymentService ?? SalePaymentService(),
       _storageService = storageService;

  final SaleService service;
  final ProductService productService;
  final CustomerService customerService;
  final CurrencyService currencyService;
  final PaymentTypeService paymentTypeService;
  final SalePaymentService salePaymentService;
  final IStorageService? _storageService;
  IStorageService get _layoutStorage => _storageService ?? storage;
  final categories = <Map<String, dynamic>>[].obs;
  final customers = <Map<String, dynamic>>[].obs;
  final paymentTypes = <Map<String, dynamic>>[].obs;
  final currencies = <Map<String, dynamic>>[].obs;
  final currency = Rxn<Map<String, dynamic>>();
  final selectedCustomer = Rxn<Map<String, dynamic>>();
  final selectedPaymentType = Rxn<Map<String, dynamic>>();
  final cart = <int, Map<String, dynamic>>{}.obs;

  /// Null keeps the adaptive default until the user chooses a layout.
  final productGridView = RxnBool();
  final productGridColumns = 2.obs;
  Future<void> _layoutSave = Future.value();
  final isLoading = false.obs;
  final isCustomersLoading = false.obs;
  final isPaymentTypesLoading = false.obs;
  final isProcessingPayment = false.obs;

  final searchCtr = SearchController();
  final productLoadError = ''.obs;
  final customerLoadError = ''.obs;
  final paymentTypesLoadError = ''.obs;
  final currencyLoadError = ''.obs;
  final checkoutError = ''.obs;
  final isConfirmingPayment = false.obs;
  bool get checkoutBusy =>
      isConfirmingPayment.value || isProcessingPayment.value;
  bool get canCheckout =>
      !checkoutBusy &&
      cart.isNotEmpty &&
      selectedCustomer.value != null &&
      selectedPaymentType.value != null;

  /// Exchange rates share a base, so their ratio gives riel per US dollar.
  double? get usdToKhrRate {
    double? rateFor(String code) {
      final row = currencies.firstWhereOrNull(
        (item) => item['code']?.toString().trim().toUpperCase() == code,
      );
      final rate = double.tryParse(row?['exchange_rate']?.toString() ?? '');
      return rate != null && rate.isFinite && rate > 0 ? rate : null;
    }

    final usd = rateFor('USD');
    final khr = rateFor('KHR');
    if (usd == null || khr == null) return null;
    final result = khr / usd;
    return result.isFinite && result > 0 ? result : null;
  }

  @override
  void onClose() {
    searchCtr.onClose();
    super.onClose();
  }

  /// Categories with products filtered by the search keyword.
  /// Categories that have no matching products are hidden while searching.
  List<Map<String, dynamic>> get filteredCategories {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) return categories;

    final result = <Map<String, dynamic>>[];

    for (final category in categories) {
      final products = (category['products'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .where((product) {
            final name = (product['name'] ?? '').toString().toLowerCase();
            final barcode = (product['barcode'] ?? '').toString().toLowerCase();

            return name.contains(keyword) ||
                BarcodeUtils.matches(barcode, keyword);
          })
          .toList();

      if (products.isNotEmpty) {
        result.add({...category, 'products': products});
      }
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    loadProductLayout();
    loadProductCategories();
    loadCustomers();
    loadPaymentTypes();
    loadCurrency();
  }

  void loadProductLayout() {
    final saved = _layoutStorage.readStorage<dynamic>(StorageKey.saleLayout);
    if (saved is! Map) return;
    final grid = saved['grid'];
    final columns = saved['columns'];
    if (grid is bool) productGridView.value = grid;
    if (columns is int &&
        columns >= 2 &&
        columns <= AppTokens.saleGridMaxColumns) {
      productGridColumns.value = columns;
    }
  }

  Future<void> setProductLayout({required bool grid, int? columns}) {
    if (columns != null &&
        (columns < 2 || columns > AppTokens.saleGridMaxColumns)) {
      return Future.value();
    }
    if (columns != null) productGridColumns.value = columns;
    productGridView.value = grid;
    final preference = {'grid': grid, 'columns': productGridColumns.value};
    _layoutSave = _layoutSave
        .then(
          (_) => _layoutStorage.writeStorage(StorageKey.saleLayout, preference),
        )
        .catchError((Object error) {
          debugPrint('Unable to save sale layout: $error');
        });
    return _layoutSave;
  }

  /// The sale grid and cart total are priced in the shop's default currency.
  Future<void> loadCurrency() async {
    currencyLoadError.value = '';
    try {
      final response = await currencyService.getCurrencies();
      if (response is! List) throw const FormatException('Expected list');
      {
        final rows = List<Map<String, dynamic>>.from(response);
        currencies.assignAll(rows);
        currency.value =
            rows.firstWhereOrNull((c) => c['is_default'] == true) ??
            rows.firstOrNull;
      }
    } catch (error) {
      currencyLoadError.value = 'Unable to load currency. Please try again.'.tr;
    }
  }

  Future<void> loadPaymentTypes() async {
    paymentTypesLoadError.value = '';
    try {
      isPaymentTypesLoading.value = true;
      final response = await paymentTypeService.getPaymentTypes();
      if (response is! List) throw const FormatException('Expected list');
      {
        paymentTypes.value = List<Map<String, dynamic>>.from(
          response,
        ).where((paymentType) => paymentType['status'] == true).toList();
        selectedPaymentType.value =
            paymentTypes.firstWhereOrNull(
              (row) => row['id'] == selectedPaymentType.value?['id'],
            ) ??
            paymentTypes.firstOrNull;
      }
    } catch (error) {
      paymentTypesLoadError.value =
          'Unable to load payment types. Please try again.'.tr;
    } finally {
      isPaymentTypesLoading.value = false;
    }
  }

  void selectPaymentType(Map<String, dynamic> paymentType) {
    if (checkoutBusy) return;
    selectedPaymentType.value = paymentType;
  }

  Future<void> loadCustomers() async {
    customerLoadError.value = '';
    try {
      isCustomersLoading.value = true;
      final response = await customerService.getCustomers();
      if (response is! List) throw const FormatException('Expected list');
      {
        customers.value = List<Map<String, dynamic>>.from(response);
        selectedCustomer.value =
            customers.firstWhereOrNull(
              (row) => row['id'] == selectedCustomer.value?['id'],
            ) ??
            customers.firstOrNull;
      }
    } catch (error) {
      customerLoadError.value =
          'Unable to load customers. Please try again.'.tr;
    } finally {
      isCustomersLoading.value = false;
    }
  }

  void selectCustomer(Map<String, dynamic> customer) {
    if (checkoutBusy) return;
    selectedCustomer.value = customer;
  }

  Future<void> loadProductCategories() async {
    productLoadError.value = '';
    try {
      isLoading.value = true;
      final response = await service.getProductCategories();
      if (response is! List) throw const FormatException('Expected list');
      {
        final categoryList = response.map<Map<String, dynamic>>((rawCategory) {
          if (rawCategory is! Map) {
            throw const FormatException('Invalid category');
          }
          final category = Map<String, dynamic>.from(rawCategory);
          final rawProducts = category['products'] ?? [];
          if (rawProducts is! List) {
            throw const FormatException('Invalid products');
          }
          category['products'] = rawProducts.map<Map<String, dynamic>>((
            rawProduct,
          ) {
            if (rawProduct is! Map) {
              throw const FormatException('Invalid product');
            }
            final product = Map<String, dynamic>.from(rawProduct);
            final id = int.tryParse(product['id']?.toString() ?? '');
            if (id == null) throw const FormatException('Invalid product ID');
            return {...product, 'id': id};
          }).toList();
          return category;
        }).toList();
        await _mergeProductBarcodes(categoryList);
        categories.value = categoryList;
      }
    } catch (error) {
      productLoadError.value = 'Unable to load products. Please try again.'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// The product-category endpoint does not always return the barcode.
  /// Merge barcodes from the product endpoint so barcode search works.
  Future<void> _mergeProductBarcodes(
    List<Map<String, dynamic>> categoryList,
  ) async {
    try {
      final response = await productService.getProducts();
      if (response is! List) return;

      final barcodes = <int, String>{};

      for (final product in response) {
        if (product is! Map) continue;

        final id = int.tryParse(product['id']?.toString() ?? '');
        final barcode = product['barcode']?.toString().trim() ?? '';

        if (id != null && barcode.isNotEmpty) {
          barcodes[id] = barcode;
        }
      }

      for (final category in categoryList) {
        final products = category['products'];
        if (products is! List) continue;

        for (final product in products) {
          if (product is! Map) continue;

          final id = int.tryParse(product['id']?.toString() ?? '');
          final barcode = barcodes[id];

          if (barcode != null) {
            product['barcode'] = barcode;
          }
        }
      }
    } catch (_) {
      // Barcode lookup is optional; keep the product list usable if it fails.
    }
  }

  void addProduct(Map<String, dynamic> product) {
    if (checkoutBusy) return;
    final id = product['id'] as int;
    final quantity = (cart[id]?['qty'] as int? ?? 0) + 1;
    cart[id] = {...product, 'qty': quantity};
  }

  void changeQuantity(int productId, int change) {
    if (checkoutBusy) return;
    final product = cart[productId];
    if (product == null) return;

    final quantity = (product['qty'] as int) + change;
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = {...product, 'qty': quantity};
    }
  }

  List<Map<String, dynamic>> get selectedProducts => cart.values.toList();

  int get totalItems => cart.values.fold<int>(
    0,
    (total, product) => total + (product['qty'] as int),
  );

  double get subtotal => cart.values.fold<double>(
    0,
    (total, product) =>
        total +
        (double.tryParse(product['sale_price']?.toString() ?? '') ?? 0) *
            (product['qty'] as int),
  );

  void onCurrentSale() {
    Get.toNamed(AppRoutes.currentSale);
  }

  Future<void> onPayment() async {
    if (checkoutBusy) return;
    final customer = selectedCustomer.value;
    final paymentType = selectedPaymentType.value;
    final userId = int.tryParse(
      storage.lastUserLoginRead['user']?['id']?.toString() ?? '',
    );

    if (selectedProducts.isEmpty || customer == null || paymentType == null) {
      ToastWidget.show(
        message:
            'Select a customer, payment type, and at least one product.'.tr,
        type: ToastType.error,
      );
      return;
    }
    if (userId == null) {
      ToastWidget.show(
        message: 'Unable to identify the logged-in user.'.tr,
        type: ToastType.error,
      );
      return;
    }
    if (isProcessingPayment.value) return;

    isConfirmingPayment.value = true;
    checkoutError.value = '';
    try {
      final confirmedProducts = selectedProducts
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      final method = paymentType['name']?.toString() ?? '';
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirm payment'.tr),
          content: Text(
            'Charge @amount to @customer using @method?'.trParams({
              'amount': CurrencyFormatter.format(subtotal, currency.value),
              'customer': customer['name']?.toString() ?? '',
              'method': method,
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('Confirm'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (confirmed != true) return;

      isProcessingPayment.value = true;
      int? saleId;
      var legacyCheckout = false;
      var checkoutRejected = false;
      try {
        final now = DateTime.now().toUtc();
        final reference = 'SALE-${now.microsecondsSinceEpoch}';
        final saleData = <String, dynamic>{
          'user_id': userId,
          'customer_id': customer['id'],
          'sale_date': now.toIso8601String(),
          'status': 'completed',
          'payment_method': method,
          'sale_items': confirmedProducts
              .map(
                (product) => {
                  'product_id': product['id'],
                  'qty': product['qty'],
                },
              )
              .toList(),
        };
        dynamic saleResponse;
        try {
          saleResponse = await service.createCheckout({
            ...saleData,
            'reference_no': reference,
          });
        } on ApiException catch (error) {
          final unsupported =
              (error.statusCode == 404 && error.message == 'Not Found') ||
              (error.statusCode == 405 &&
                  error.message == 'Method Not Allowed');
          if (!unsupported) {
            checkoutRejected =
                error.statusCode >= 400 && error.statusCode < 500;
            rethrow;
          }
          legacyCheckout = true;
          saleResponse = await _createSale(saleData);
        }

        SaleListController.invalidateCache();
        saleId = int.tryParse(saleResponse['id']?.toString() ?? '');
        final amount = double.tryParse(
          saleResponse['total_amount']?.toString() ?? '',
        );
        if (saleId == null ||
            amount == null ||
            !amount.isFinite ||
            amount <= 0) {
          throw Exception('The sale response did not include an ID and total.');
        }

        if (legacyCheckout) {
          await salePaymentService.createSalePayment({
            'user_id': userId,
            'sale_id': saleId,
            'amount': amount,
            'payment_method': method,
            'reference_no': reference,
            'payment_date': now.toIso8601String(),
            'note': 'Sale payment',
            'created_at': now.toIso8601String(),
          });
        }
        SaleListController.invalidateCache();

        final receipt = {
          'customer': customer['name']?.toString() ?? '',
          'payment_method': method,
          'payment_date': now.toIso8601String(),
          'transaction_id': reference,
          'subtotal': saleResponse['subtotal'] ?? subtotal,
          'total': amount,
          'currency': currency.value,
        };
        cart.clear();
        selectedCustomer.value = null;
        selectedPaymentType.value = null;
        Get.offNamed(AppRoutes.paymentSuccess, arguments: receipt);
      } catch (error) {
        checkoutError.value =
            'Unable to complete payment. Please try again.'.tr;
        if (!legacyCheckout && !checkoutRejected) {
          checkoutError.value =
              'The sale may have been created. Check Sales before trying again.'
                  .tr;
        } else if (legacyCheckout && saleId != null) {
          try {
            await service.deleteSale(saleId);
            SaleListController.invalidateCache();
          } catch (_) {
            checkoutError.value =
                'The sale may have been created. Check Sales before trying again.'
                    .tr;
          }
        }
        ToastWidget.show(message: checkoutError.value, type: ToastType.error);
      } finally {
        isProcessingPayment.value = false;
      }
    } finally {
      isConfirmingPayment.value = false;
    }
  }

  Future<dynamic> _createSale(Map<String, dynamic> data) async {
    try {
      return await service.createSale(data);
    } catch (error) {
      final message = error.toString();
      final invoiceRequired =
          message.contains('invoice_no') &&
          (message.contains('Field required') || message.contains('missing'));

      if (!invoiceRequired) rethrow;

      // Older deployed backends require invoice_no even though the current
      // backend generates it automatically. Send one only for that case.
      final now = DateTime.now();
      final date = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';
      final time =
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';

      return await service.createSale({
        ...data,
        'invoice_no': 'SALE-$date-$time',
      });
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void onConfirm() {
    Get.offNamed(AppRoutes.paymentSuccess);
  }
}
