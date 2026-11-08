import 'package:flutter/material.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/purchase_payment/widget/add_purchase_payment_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/edit_purchase_payment_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class PurchasePaymentController extends GetxController {
  PurchasePaymentController({
    PurchasePaymentService? service,
    PurchaseController? purchaseCtr,
    PaymentTypeController? paymentTypeCtr,
    CurrencyController? currencyCtr,
  })  : service = service ?? PurchasePaymentService(),
        purchaseCtr = purchaseCtr ?? Get.put(PurchaseController()),
        paymentTypeCtr = paymentTypeCtr ?? Get.put(PaymentTypeController()),
        currencyCtr = currencyCtr ?? Get.put(CurrencyController());

  final PurchasePaymentService service;
  final PurchaseController purchaseCtr;
  final PaymentTypeController paymentTypeCtr;
  final CurrencyController currencyCtr;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final purchasePaymentList = <Map<String, dynamic>>[].obs;

  final formKey = GlobalKey<FormState>();
  final paymentNoCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final selectedPaymentTypeId = RxnInt();
  final selectedCurrencyId = RxnInt();
  final selectedPurchaseId = RxnInt();
  final editingPaymentId = RxnInt();
  final paymentStatus = "completed".obs;

  final Rx<DateTime> purchaseDate = DateTime.now().obs;

  Map<String, dynamic>? _originalPayment;
  Map<String, dynamic>? get originalPayment => _originalPayment;

  bool get isEditing => editingPaymentId.value != null;

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshCache) {
      purchasePaymentList.value = List<Map<String, dynamic>>.from(_cache);
    } else {
      onGetPaymentList();
    }
  }

  Future<void> onGetPaymentList() async {
    try {
      isLoading.value = true;

      final resp = await service.getPurchasePayments();

      if (resp is List) {
        purchasePaymentList.value = List<Map<String, dynamic>>.from(resp);

        _cache
          ..clear()
          ..addAll(purchasePaymentList);
        _cachedAt = DateTime.now();
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void pickPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  Future<void> addPurchasePayment(BuildContext context) async {
    editingPaymentId.value = null;
    _originalPayment = null;
    paymentNoCtrl.clear();
    amountCtrl.clear();
    noteCtrl.clear();
    selectedPurchaseId.value = null;
    selectedPaymentTypeId.value = null;
    selectedCurrencyId.value = null;
    paymentStatus.value = "completed";
    purchaseDate.value = DateTime.now();

    await purchaseCtr.onGetPurchaseList();
    if (!context.mounted) return;
    AppBottomSheets.show(context, child: AddPurchasePaymentWidget());
  }

  Map<String, dynamic>? get selectedPurchase {
    final purchaseId = selectedPurchaseId.value;
    if (purchaseId == null) return null;

    for (final purchase in purchaseCtr.purchaseList) {
      if (int.tryParse(purchase["id"].toString()) == purchaseId) {
        return purchase;
      }
    }
    return null;
  }

  double get selectedPurchaseDue =>
      _toDouble(selectedPurchase?["due_amount"]);

  double get maxAmount {
    if (!isEditing) return selectedPurchaseDue;

    final currentDue = _toDouble(_originalPayment?['purchase']?['due_amount']);
    final originalAmount = _toDouble(_originalPayment?['amount']);
    final originalStatus =
        _originalPayment?['status']?.toString().trim().toLowerCase();

    return currentDue + (originalStatus == 'completed' ? originalAmount : 0);
  }

  Future<void> editPurchasePayment(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    _originalPayment = payment;
    editingPaymentId.value = int.tryParse(payment['id']?.toString() ?? '');
    selectedPurchaseId.value =
        int.tryParse(payment['purchase']?['id']?.toString() ?? '');
    selectedPaymentTypeId.value =
        int.tryParse(payment['payment_type']?['id']?.toString() ?? '');
    selectedCurrencyId.value =
        int.tryParse(payment['currency']?['id']?.toString() ?? '');
    paymentNoCtrl.text = payment['payment_no']?.toString() ?? '';
    amountCtrl.text = payment['amount']?.toString() ?? '';
    noteCtrl.text = payment['note']?.toString() ?? '';
    paymentStatus.value = payment['status']?.toString() ?? 'completed';
    purchaseDate.value =
        DateTime.tryParse(payment['payment_date']?.toString() ?? '')?.toLocal() ??
            DateTime.now();

    await purchaseCtr.onGetPurchaseList();
    if (!context.mounted) return;
    AppBottomSheets.show(context, child: EditPurchasePaymentWidget());
  }

  Future<void> onSavePurchasePayment(BuildContext context) async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final purchase = selectedPurchase;
    final purchaseId = selectedPurchaseId.value;
    final supplierId = int.tryParse(
      purchase?["supplier"]?["id"].toString() ?? "",
    );
    final paymentTypeId = selectedPaymentTypeId.value;
    final currencyId = selectedCurrencyId.value;
    final amount = double.tryParse(amountCtrl.text.trim());

    if (purchase == null ||
        purchaseId == null ||
        supplierId == null ||
        paymentTypeId == null ||
        currencyId == null ||
        amount == null ||
        amount > selectedPurchaseDue) {
      ToastWidget.show(
        message: "Check the payment details and purchase balance".tr,
        type: ToastType.error,
      );
      return;
    }

    final payload = {
      "payment_no": paymentNoCtrl.text.trim(),
      "purchase_id": purchaseId,
      "supplier_id": supplierId,
      "payment_type_id": paymentTypeId,
      "currency_id": currencyId,
      "amount": amount,
      "payment_date": purchaseDate.value.toUtc().toIso8601String(),
      "status": paymentStatus.value,
      "note": noteCtrl.text.trim(),
    };

    isSaving.value = true;
    try {
      await service.createPurchasePayment(payload);
      await Future.wait([onGetPaymentList(), purchaseCtr.onGetPurchaseList()]);
      if (!context.mounted) return;

      ToastWidget.show(
        message: "Purchase payment created successfully".tr,
        type: ToastType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onUpdatePurchasePayment(BuildContext context) async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final paymentId = editingPaymentId.value;
    final purchaseId = selectedPurchaseId.value;
    final supplierId = int.tryParse(
      _originalPayment?['supplier']?['id']?.toString() ?? '',
    );
    final paymentTypeId = selectedPaymentTypeId.value;
    final currencyId = selectedCurrencyId.value;
    final amount = double.tryParse(amountCtrl.text.trim());

    if (paymentId == null ||
        purchaseId == null ||
        supplierId == null ||
        paymentTypeId == null ||
        currencyId == null ||
        amount == null ||
        amount <= 0 ||
        amount > maxAmount) {
      ToastWidget.show(
        message: "Check the payment details and purchase balance".tr,
        type: ToastType.error,
      );
      return;
    }

    final payload = {
      "payment_no": paymentNoCtrl.text.trim(),
      "purchase_id": purchaseId,
      "supplier_id": supplierId,
      "payment_type_id": paymentTypeId,
      "currency_id": currencyId,
      "amount": amount,
      "payment_date": purchaseDate.value.toUtc().toIso8601String(),
      "status": paymentStatus.value,
      "note": noteCtrl.text.trim(),
    };

    isSaving.value = true;
    try {
      await service.updatePurchasePayment(paymentId, payload);
      await Future.wait([onGetPaymentList(), purchaseCtr.onGetPurchaseList()]);
      if (!context.mounted) return;

      ToastWidget.show(
        message: "Purchase payment updated successfully".tr,
        type: ToastType.success,
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onDeletePurchasePayment(BuildContext context, int id) async {
    await showConfirmDialog(
      context: context,
      message: "Do you want to delete this purchase payment?".tr,
      onConfirm: () async {
        try {
          await service.deletePurchasePayment(id);
          await Future.wait([
            onGetPaymentList(),
            purchaseCtr.onGetPurchaseList(),
          ]);

          ToastWidget.show(
            message: "Purchase payment deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (e) {
          ToastWidget.show(message: e.toString(), type: ToastType.error);
        }
      },
    );
  }

  @override
  void onClose() {
    paymentNoCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
