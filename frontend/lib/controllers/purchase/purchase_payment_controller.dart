import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/purchase_payment/widget/add_purchase_payment_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/edit_purchase_payment_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentController extends GetxController {
  PurchasePaymentController({
    PurchasePaymentService? service,
    PurchaseController? purchaseCtr,
    PaymentTypeController? paymentTypeCtr,
    CurrencyController? currencyCtr,
  }) : service = service ?? PurchasePaymentService(),
       purchaseCtr = purchaseCtr ?? Get.put(PurchaseController()),
       paymentTypeCtr = paymentTypeCtr ?? Get.put(PaymentTypeController()),
       currencyCtr = currencyCtr ?? Get.put(CurrencyController());

  final PurchasePaymentService service;
  final PurchaseController purchaseCtr;
  final PaymentTypeController paymentTypeCtr;
  final CurrencyController currencyCtr;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final loadError = ''.obs;
  final formError = ''.obs;
  final purchasePaymentList = <Map<String, dynamic>>[].obs;
  final searchPaymentList = <Map<String, dynamic>>[].obs;

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

  String _query = '';
  Worker? _searchWorker;
  bool _formOpen = false;
  bool _openingForm = false;

  bool get isEditing => editingPaymentId.value != null;

  @override
  void onInit() {
    super.onInit();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value.trim().toLowerCase();
    _searchWorker = ever(search.keyword, searchPayments);
    onGetPaymentList();
  }

  Future<void> onGetPaymentList() async {
    if (isLoading.value || isClosed) return;
    loadError.value = '';
    try {
      isLoading.value = true;
      final resp = await service.getPurchasePayments();
      if (resp is! List) throw const FormatException('Invalid payment list');
      purchasePaymentList.assignAll(List<Map<String, dynamic>>.from(resp));
      searchPayments(_query);
    } catch (_) {
      if (!isClosed) {
        loadError.value =
            'Unable to load purchase payments. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => onGetPaymentList();

  void searchPayments(String keyword) {
    _query = keyword.trim().toLowerCase();
    searchPaymentList.assignAll(
      _query.isEmpty
          ? purchasePaymentList
          : purchasePaymentList.where((payment) {
              final purchase = payment['purchase'];
              final supplier = payment['supplier'];
              final paymentType = payment['payment_type'];
              final currency = payment['currency'];
              final values = [
                payment['payment_no'],
                payment['note'],
                payment['status'],
                supplier is Map ? supplier['name'] : null,
                purchase is Map ? purchase['invoice_no'] : null,
                paymentType is Map ? paymentType['name'] : null,
                currency is Map ? currency['name'] : null,
              ];
              return values.any(
                (value) =>
                    (value ?? '').toString().toLowerCase().contains(_query),
              );
            }),
    );
  }

  void pickPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  Future<void> addPurchasePayment(BuildContext context) async {
    if (_formOpen ||
        _openingForm ||
        isSaving.value ||
        isOpeningEdit.value ||
        isClosed) {
      return;
    }
    final route = ModalRoute.of(context);
    _openingForm = true;
    formError.value = '';
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

    try {
      await purchaseCtr.onGetPurchaseList();
      if (isClosed ||
          !context.mounted ||
          route?.isCurrent != true ||
          _formOpen) {
        return;
      }
      _showForm(context, AddPurchasePaymentWidget());
    } finally {
      _openingForm = false;
    }
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
      parseAmount(selectedPurchase?["due_amount"]);

  double get maxAmount {
    if (!isEditing) return selectedPurchaseDue;

    final refreshedPurchase = selectedPurchase;
    final currentDue = refreshedPurchase != null
        ? parseAmount(refreshedPurchase['due_amount'])
        : parseAmount(_originalPayment?['purchase']?['due_amount']);
    final originalAmount = parseAmount(_originalPayment?['amount']);
    final originalStatus = _originalPayment?['status']
        ?.toString()
        .trim()
        .toLowerCase();

    return currentDue + (originalStatus == 'completed' ? originalAmount : 0);
  }

  Future<void> editPurchasePayment(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    final route = ModalRoute.of(context);
    formError.value = '';
    isOpeningEdit.value = true;
    try {
      _originalPayment = payment;
      editingPaymentId.value = int.tryParse(payment['id']?.toString() ?? '');
      selectedPurchaseId.value = int.tryParse(
        payment['purchase']?['id']?.toString() ?? '',
      );
      selectedPaymentTypeId.value = int.tryParse(
        payment['payment_type']?['id']?.toString() ?? '',
      );
      selectedCurrencyId.value = int.tryParse(
        payment['currency']?['id']?.toString() ?? '',
      );
      paymentNoCtrl.text = payment['payment_no']?.toString() ?? '';
      amountCtrl.text = payment['amount']?.toString() ?? '';
      noteCtrl.text = payment['note']?.toString() ?? '';
      paymentStatus.value = payment['status']?.toString() ?? 'completed';
      purchaseDate.value =
          DateTime.tryParse(
            payment['payment_date']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      await purchaseCtr.onGetPurchaseList();
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      _showForm(context, EditPurchasePaymentWidget());
    } catch (_) {
      if (!isClosed) {
        formError.value =
            'Unable to open purchase payment. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> _showForm(BuildContext context, Widget child) async {
    _formOpen = true;
    try {
      if (MediaQuery.sizeOf(context).width >= 840) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            constraints: const BoxConstraints(maxWidth: 720),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        );
      } else {
        await AppBottomSheets.show(
          context,
          child: child,
          isDismissible: false,
          enableDrag: false,
          constraints: const BoxConstraints(maxWidth: 760),
        );
      }
    } finally {
      _formOpen = false;
    }
  }

  Future<void> onSavePurchasePayment(BuildContext context) =>
      _persistPurchasePayment(context, editing: false);

  Future<void> onUpdatePurchasePayment(BuildContext context) =>
      _persistPurchasePayment(context, editing: true);

  Future<void> _persistPurchasePayment(
    BuildContext context, {
    required bool editing,
  }) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    if (!(formKey.currentState?.validate() ?? false)) return;

    final paymentId = editingPaymentId.value;
    final purchaseId = selectedPurchaseId.value;
    final supplier =
        _originalPayment?['supplier'] ?? selectedPurchase?['supplier'];
    final supplierId = int.tryParse(supplier?['id']?.toString() ?? '');
    final paymentTypeId = selectedPaymentTypeId.value;
    final currencyId = selectedCurrencyId.value;
    final amount = double.tryParse(amountCtrl.text.trim());

    if (purchaseId == null ||
        supplierId == null ||
        paymentTypeId == null ||
        currencyId == null ||
        amount == null ||
        (editing && paymentId == null)) {
      formError.value = "Check the payment details and purchase balance".tr;
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

    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);

    isSaving.value = true;
    try {
      final resp = editing
          ? await service.updatePurchasePayment(paymentId!, payload)
          : await service.createPurchasePayment(payload);
      if (resp is Map) {
        final saved = Map<String, dynamic>.from(resp);
        final savedId = int.tryParse(saved['id']?.toString() ?? '');
        final index = purchasePaymentList.indexWhere(
          (payment) => payment['id'] == savedId,
        );
        if (index >= 0) {
          purchasePaymentList[index] = saved;
        } else {
          purchasePaymentList.add(saved);
        }
        searchPayments(_query);
      }
      await Future.wait([onGetPaymentList(), purchaseCtr.onGetPurchaseList()]);
      if (context.mounted && route is PopupRoute && route.isCurrent) {
        navigator.pop();
      }
      isSaving.value = false;
      ToastWidget.show(
        message: editing
            ? "Purchase payment updated successfully".tr
            : "Purchase payment created successfully".tr,
        type: ToastType.success,
      );
    } catch (_) {
      if (!isClosed) {
        formError.value =
            'Unable to save purchase payment. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  Future<void> onDeletePurchasePayment(
    BuildContext context,
    int id, {
    VoidCallback? onDeleted,
  }) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    await showConfirmDialog(
      context: context,
      message: "Do you want to delete this purchase payment?".tr,
      onConfirm: () async {
        isSaving.value = true;
        try {
          await service.deletePurchasePayment(id);
          purchasePaymentList.removeWhere((payment) => payment['id'] == id);
          searchPayments(_query);
          await Future.wait([
            onGetPaymentList(),
            purchaseCtr.onGetPurchaseList(),
          ]);
          onDeleted?.call();
          ToastWidget.show(
            message: "Purchase payment deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (_) {
          formError.value =
              'Unable to delete purchase payment. Please try again.'.tr;
          ToastWidget.show(message: formError.value, type: ToastType.error);
        } finally {
          if (!isClosed) isSaving.value = false;
        }
      },
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    paymentNoCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
