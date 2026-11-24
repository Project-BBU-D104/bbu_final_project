import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'dart:math';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
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
  }) : service = service ?? SaleService(),
       productService = productService ?? ProductService(),
       customerService = customerService ?? CustomerService(),
       currencyService = currencyService ?? CurrencyService(),
       paymentTypeService = paymentTypeService ?? PaymentTypeService();

  final SaleService service;
  final ProductService productService;
  final CustomerService customerService;
  final CurrencyService currencyService;
  final PaymentTypeService paymentTypeService;

  Map<int, Map<String, dynamic>>? _catalog;
  final categories = <Map<String, dynamic>>[].obs;
  final customers = <Map<String, dynamic>>[].obs;
  final paymentTypes = <Map<String, dynamic>>[].obs;
  final currency = Rxn<Map<String, dynamic>>();
  final selectedCustomer = Rxn<Map<String, dynamic>>();
  final selectedPaymentType = Rxn<Map<String, dynamic>>();
  final cart = <(int, int), Map<String, dynamic>>{}.obs;
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
  final _pending = Rxn<Map<String, dynamic>>();
  String? _owner;
  final checkoutConflict = false.obs;
  String? get _scope {
    final id = storage.lastUserLoginRead['user']?['id'];
    return id == null ? null : '${service.baseUrl}|$id';
  }

  bool get hasPendingCheckout => _pending.value != null && _owner == _scope;
  bool get cartLocked => checkoutBusy || hasPendingCheckout;
  Map<String, dynamic> get _entries => Map<String, dynamic>.from(
    storage.readStorage<Map>(StorageKey.pendingCheckouts) ?? {},
  );

  void restorePendingCheckout() {
    _owner = _scope;
    _pending.value = _entries[_owner];
    checkoutConflict.value = _pending.value?['conflict'] == true;
  }

  Future<void> _save(String owner, Map<String, dynamic>? entry) async {
    final entries = _entries;
    if (entry == null) {
      entries.remove(owner);
    } else {
      entries[owner] = entry;
    }
    await storage.writeStorage(StorageKey.pendingCheckouts, entries);
    if (_scope == owner) {
      _owner = owner;
      _pending.value = entry;
      checkoutConflict.value = entry?['conflict'] == true;
    }
  }

  Future<void> dismissConflict() async {
    if (checkoutBusy || !hasPendingCheckout || !checkoutConflict.value) return;
    isProcessingPayment.value = true;
    try {
      await _save(_owner!, null);
      checkoutError.value = '';
    } catch (_) {
      checkoutError.value = 'Unable to save checkout. Please try again.'.tr;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  bool get canCheckout =>
      !checkoutBusy &&
      cart.isNotEmpty &&
      cart.values.every((row) => row['qty'] <= row['available_qty']) &&
      selectedCustomer.value != null &&
      selectedPaymentType.value != null;

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
    restorePendingCheckout();
    loadProductCategories();
    loadCustomers();
    loadPaymentTypes();
    loadCurrency();
  }

  /// The sale grid and cart total are priced in the shop's default currency.
  Future<void> loadCurrency() async {
    currencyLoadError.value = '';
    try {
      final response = await currencyService.getCurrencies();
      if (response is! List) throw const FormatException('Expected list');
      {
        final currencies = List<Map<String, dynamic>>.from(response);
        currency.value =
            currencies.firstWhereOrNull((c) => c['is_default'] == true) ??
            currencies.firstOrNull;
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
    if (cartLocked) return;
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
    if (cartLocked) return;
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
        _catalog = {
          for (final category in categoryList)
            for (final product in category['products'])
              product['id'] as int: product as Map<String, dynamic>,
        };
        categories.value = categoryList;
        if (cart.isNotEmpty) {
          final limits = {
            for (final category in categoryList)
              for (final product in category['products'])
                for (final row in warehouses(product))
                  (product['id'] as int, row['warehouse_id'] as int):
                      row['qty'] as int,
          };
          cart.assignAll({
            for (final entry in cart.entries)
              entry.key: {
                ...entry.value,
                'available_qty': limits[entry.key] ?? 0,
              },
          });
        }
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

  static List<Map<String, dynamic>> warehouses(Map<String, dynamic> product) {
    final rows = product['warehouse_availability'];
    if (rows is! List ||
        rows.any(
          (r) =>
              r is! Map<String, dynamic> ||
              r['warehouse_id'] is! int ||
              r['warehouse_name'] is! String ||
              r['qty'] is! int,
        )) {
      return [];
    }
    return rows.cast<Map<String, dynamic>>();
  }

  void addProduct(Map<String, dynamic> product, {int? warehouseId}) {
    if (cartLocked) return;
    if (_catalog != null) {
      final current = _catalog![product['id']];
      if (current == null) return;
      product = current;
    }
    final rows = warehouses(product);
    final row = warehouseId == null
        ? rows.singleOrNull
        : rows.firstWhereOrNull((r) => r['warehouse_id'] == warehouseId);
    if (row == null) return;
    final key = (product['id'] as int, row['warehouse_id'] as int);
    final quantity = (cart[key]?['qty'] as int? ?? 0) + 1;
    if (quantity > row['qty']) return;
    cart[key] = {
      ...product,
      'warehouse_id': key.$2,
      'warehouse_name': row['warehouse_name'],
      'available_qty': row['qty'],
      'qty': quantity,
    };
  }

  void changeQuantity(int productId, int warehouseId, int change) {
    if (cartLocked) return;
    final key = (productId, warehouseId);
    final product = cart[key];
    if (product == null) return;
    final quantity = (product['qty'] as int) + change;
    if (quantity <= 0) {
      cart.remove(key);
    } else if (change < 0 || quantity <= product['available_qty']) {
      cart[key] = {...product, 'qty': quantity};
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
    final owner = _scope;
    if (owner == null) {
      ToastWidget.show(
        message: 'Unable to identify the logged-in user.'.tr,
        type: ToastType.error,
      );
      return;
    }
    restorePendingCheckout();
    if (hasPendingCheckout) {
      if (!checkoutConflict.value) await _submit(owner, _pending.value!);
      return;
    }
    final customer = selectedCustomer.value;
    final paymentType = selectedPaymentType.value;
    if (selectedProducts.isEmpty || customer == null || paymentType == null) {
      ToastWidget.show(
        message:
            'Select a customer, payment type, and at least one product.'.tr,
        type: ToastType.error,
      );
      return;
    }
    if (!canCheckout) return;
    isConfirmingPayment.value = true;
    checkoutError.value = '';
    try {
      final confirmedProducts = selectedProducts
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      final total = subtotal;
      final displayCurrency = currency.value;
      final method = paymentType['name']?.toString() ?? '';
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirm payment'.tr),
          content: Text(
            'Charge @amount to @customer using @method?'.trParams({
              'amount': CurrencyFormatter.format(total, displayCurrency),
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

      if (_scope != owner) return;
      final random = Random.secure();
      final id = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final entry = {
        'currency': displayCurrency,
        'request': {
          'checkout_id': id,
          'customer_id': customer['id'],
          'payment_type_id': paymentType['id'],
          'expected_total': total.toStringAsFixed(2),
          'sale_items': [
            for (final p in confirmedProducts)
              {
                'product_id': p['id'],
                'warehouse_id': p['warehouse_id'],
                'qty': p['qty'],
              },
          ],
        },
      };
      try {
        await _save(owner, entry);
      } catch (_) {
        checkoutError.value = 'Unable to save checkout. Please try again.'.tr;
        return;
      }
      if (_scope == owner) await _submit(owner, entry);
    } finally {
      isConfirmingPayment.value = false;
    }
  }

  Future<void> _submit(String owner, Map<String, dynamic> entry) async {
    isProcessingPayment.value = true;
    checkoutError.value = '';
    final request = Map<String, dynamic>.from(entry['request']);
    try {
      late final Map<String, dynamic> receipt;
      try {
        receipt = await service.checkout(request);
      } on ApiException catch (error) {
        if (_scope != owner) return;
        checkoutError.value = error.message;
        if (error.statusCode == 404) {
          checkoutError.value = 'Checkout requires a backend upgrade.'.tr;
        } else if ([400, 422].contains(error.statusCode)) {
          await loadProductCategories();
          if (_scope != owner) return;
          _restoreDraft(request);
          await _save(owner, null);
        } else if (error.statusCode == 409) {
          checkoutConflict.value = true;
          await _save(owner, {...entry, 'conflict': true});
        }
        return;
      }
      _validateReceipt(receipt, request);
      SaleListController.invalidateCache();
      if (_scope != owner) return;
      await loadProductCategories();
      if (_scope != owner) return;
      if (productLoadError.value.isNotEmpty) {
        checkoutError.value = productLoadError.value;
        return;
      }
      await _save(owner, null);
      if (_scope != owner) return;
      cart.clear();
      selectedCustomer.value = null;
      selectedPaymentType.value = null;
      Get.offNamed(
        AppRoutes.paymentSuccess,
        arguments: {...receipt, 'currency': entry['currency']},
      );
    } catch (_) {
      checkoutError.value = 'Unable to complete payment. Please try again.'.tr;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  void _restoreDraft(Map<String, dynamic> request) {
    for (final line in request['sale_items']) {
      final id = line['product_id'] as int;
      final warehouse = line['warehouse_id'] as int;
      final key = (id, warehouse);
      final product = _catalog?[id];
      final row = product == null
          ? null
          : warehouses(
              product,
            ).firstWhereOrNull((r) => r['warehouse_id'] == warehouse);
      cart[key] = {
        ...?cart[key],
        ...?product,
        'id': id,
        'warehouse_id': warehouse,
        'name': product?['name'] ?? cart[key]?['name'] ?? '#$id',
        'warehouse_name': row?['warehouse_name'] ?? '#$warehouse',
        'available_qty': row?['qty'] ?? 0,
        'qty': line['qty'],
      };
    }
    selectedCustomer.value =
        customers.firstWhereOrNull((r) => r['id'] == request['customer_id']) ??
        (selectedCustomer.value?['id'] == request['customer_id']
            ? selectedCustomer.value
            : null);
    selectedPaymentType.value =
        paymentTypes.firstWhereOrNull(
          (r) => r['id'] == request['payment_type_id'],
        ) ??
        (selectedPaymentType.value?['id'] == request['payment_type_id']
            ? selectedPaymentType.value
            : null);
  }

  void _validateReceipt(
    Map<String, dynamic> receipt,
    Map<String, dynamic> request,
  ) {
    int cents(dynamic value) {
      if (value is! String || !RegExp(r'^\d+\.\d{2}$').hasMatch(value)) {
        throw const FormatException('Invalid receipt amount');
      }
      return int.parse(value.replaceAll('.', ''));
    }

    final expected = {
      for (final line in request['sale_items'])
        (line['product_id'], line['warehouse_id']): line['qty'],
    };
    final date = DateTime.tryParse(receipt['payment_date']?.toString() ?? '');
    if (receipt['checkout_id'] != request['checkout_id'] ||
        receipt['reference_no'] != request['checkout_id'] ||
        receipt['sale_id'] is! int ||
        receipt['sale_id'] <= 0 ||
        receipt['invoice_no'] != 'POS-${receipt['sale_id']}' ||
        receipt['customer'] is! String ||
        receipt['payment_method'] is! String ||
        date == null ||
        !date.isUtc ||
        receipt['lines'] is! List ||
        receipt['total'] != request['expected_total']) {
      throw const FormatException('Invalid receipt');
    }
    var total = 0;
    for (final line in receipt['lines']) {
      if (line is! Map ||
          line['product_name'] is! String ||
          line['qty'] is! int ||
          line['qty'] !=
              expected.remove((line['product_id'], line['warehouse_id'])) ||
          cents(line['sale_price']) * line['qty'] != cents(line['subtotal'])) {
        throw const FormatException('Invalid receipt line');
      }
      total += cents(line['subtotal']);
    }
    if (expected.isNotEmpty ||
        cents(receipt['subtotal']) != total ||
        cents(receipt['total']) != total) {
      throw const FormatException('Invalid receipt total');
    }
  }

  void onConfirm() {
    Get.offNamed(AppRoutes.paymentSuccess);
  }
}
