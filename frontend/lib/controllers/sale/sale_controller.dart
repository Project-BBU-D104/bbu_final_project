import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SaleController extends GetxController {
  final SaleService service = SaleService();
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
        categories.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
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
      final saleResponse = await service.createSale({
        'user_id': userId,
        'customer_id': customer['id'],
        'invoice_no': reference,
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

  void onConfirm() {
    Get.offNamed(AppRoutes.paymentSuccess);
  }
}
