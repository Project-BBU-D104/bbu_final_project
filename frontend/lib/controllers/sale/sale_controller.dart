import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/utils/barcode_utils.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SaleController extends GetxController {
  final SaleService service = SaleService();
  final ProductService productService = ProductService();
  final CustomerService customerService = CustomerService();
  final CurrencyService currencyService = CurrencyService();
  final PaymentTypeService paymentTypeService = PaymentTypeService();
  final SalePaymentService salePaymentService = SalePaymentService();
  final categories = <Map<String, dynamic>>[].obs;
  final customers = <Map<String, dynamic>>[].obs;
  final paymentTypes = <Map<String, dynamic>>[].obs;
  final currency = Rxn<Map<String, dynamic>>();
  final selectedCustomer = Rxn<Map<String, dynamic>>();
  final selectedPaymentType = Rxn<Map<String, dynamic>>();
  final cart = <int, Map<String, dynamic>>{}.obs;
  final isLoading = false.obs;
  final isCustomersLoading = false.obs;
  final isPaymentTypesLoading = false.obs;
  final isProcessingPayment = false.obs;

  final searchCtr = Get.put(SearchController());

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
    loadProductCategories();
    loadCustomers();
    loadPaymentTypes();
    loadCurrency();
  }

  /// The sale grid and cart total are priced in the shop's default currency.
  Future<void> loadCurrency() async {
    try {
      final response = await currencyService.getCurrencies();
      if (response is List) {
        final currencies = List<Map<String, dynamic>>.from(response);
        currency.value =
            currencies.firstWhereOrNull((c) => c['is_default'] == true) ??
            currencies.firstOrNull;
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    }
  }

  Future<void> loadPaymentTypes() async {
    try {
      isPaymentTypesLoading.value = true;
      final response = await paymentTypeService.getPaymentTypes();
      if (response is List) {
        paymentTypes.value = List<Map<String, dynamic>>.from(
          response,
        ).where((paymentType) => paymentType['status'] == true).toList();
        if (selectedPaymentType.value == null && paymentTypes.isNotEmpty) {
          selectedPaymentType.value = paymentTypes.first;
        }
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isPaymentTypesLoading.value = false;
    }
  }

  void selectPaymentType(Map<String, dynamic> paymentType) {
    selectedPaymentType.value = paymentType;
  }

  Future<void> loadCustomers() async {
    try {
      isCustomersLoading.value = true;
      final response = await customerService.getCustomers();
      if (response is List) {
        customers.value = List<Map<String, dynamic>>.from(response);
        if (selectedCustomer.value == null && customers.isNotEmpty) {
          selectedCustomer.value = customers.first;
        }
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isCustomersLoading.value = false;
    }
  }

  void selectCustomer(Map<String, dynamic> customer) {
    selectedCustomer.value = customer;
  }

  Future<void> loadProductCategories() async {
    try {
      isLoading.value = true;
      final response = await service.getProductCategories();
      if (response is List) {
        final categoryList = List<Map<String, dynamic>>.from(response);
        await _mergeProductBarcodes(categoryList);
        categories.value = categoryList;
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
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
    final id = product['id'] as int;
    final quantity = (cart[id]?['qty'] as int? ?? 0) + 1;
    cart[id] = {...product, 'qty': quantity};
  }

  void changeQuantity(int productId, int change) {
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
    final customer = selectedCustomer.value;
    final paymentType = selectedPaymentType.value;
    final userId = int.tryParse(
      storage.lastUserLoginRead['user']?['id']?.toString() ?? '',
    );

    if (selectedProducts.isEmpty || customer == null || paymentType == null) {
      ToastWidget.show(
        message: 'Select a customer, payment type, and at least one product.',
        type: ToastType.error,
      );
      return;
    }
    if (userId == null) {
      ToastWidget.show(
        message: 'Unable to identify the logged-in user.',
        type: ToastType.error,
      );
      return;
    }
    if (isProcessingPayment.value) return;

    final method = paymentType['name']?.toString() ?? '';
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm payment'),
        content: Text(
          'Charge ${CurrencyFormatter.format(subtotal, currency.value)} to '
          '${customer['name'] ?? 'customer'} using $method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (confirmed != true) return;

    isProcessingPayment.value = true;
    int? saleId;
    try {
      final now = DateTime.now().toUtc();
      final reference = 'SALE-${now.microsecondsSinceEpoch}';
      final saleResponse = await _createSale({
        'user_id': userId,
        'customer_id': customer['id'],
        'sale_date': now.toIso8601String(),
        'status': 'completed',
        'payment_method': method,
        'sale_items': selectedProducts
            .map(
              (product) => {'product_id': product['id'], 'qty': product['qty']},
            )
            .toList(),
      });

      saleId = int.tryParse(saleResponse['id']?.toString() ?? '');
      final amount = double.tryParse(
        saleResponse['total_amount']?.toString() ?? '',
      );
      if (saleId == null || amount == null) {
        throw Exception('The sale response did not include an ID and total.');
      }

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

      await service.updateSale(saleId, {'paid_amount': amount});
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
      if (saleId != null) {
        try {
          await service.deleteSale(saleId);
        } catch (_) {}
      }
      ToastWidget.show(
        message: error.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isProcessingPayment.value = false;
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
      final date =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';
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
