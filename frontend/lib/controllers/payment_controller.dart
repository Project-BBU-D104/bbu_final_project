import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/payment/widget/add_payment_widget.dart';
import 'package:frontend/screen/payment/widget/edit_payment_widget.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  PaymentController({SalePaymentService? service, SaleService? saleService})
    : service = service ?? SalePaymentService(),
      saleService = saleService ?? SaleService();

  final SalePaymentService service;
  final SaleService saleService;

  final searchCtr = SearchController();
  final loadError = ''.obs;
  final formError = ''.obs;
  final isOpeningForm = false.obs;
  final deletingIds = <int>{}.obs;
  Future<void> onRefresh() => onGetPaymentList();
  List<Map<String, dynamic>> get filteredPaymentList {
    final query = searchCtr.keyword.value.trim().toLowerCase();
    return paymentList.where((payment) {
      final sale = saleMap(payment['sale']);
      return [
        sale['invoice_no'],
        saleMap(sale['customer'])['name'],
        payment['amount'],
        payment['payment_method'],
        payment['reference_no'],
        payment['payment_date'],
        formatSaleDate(payment['payment_date']),
      ].join(' ').toLowerCase().contains(query);
    }).toList();
  }

  var isLoading = false.obs;
  var isSaving = false.obs;

  var paymentList = <Map<String, dynamic>>[].obs;
  var saleList = <Map<String, dynamic>>[].obs;

  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final methodCtrl = TextEditingController();
  final referenceCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final selectedSaleId = RxnInt();
  final editingPaymentId = RxnInt();
  final Rx<DateTime> paymentDate = DateTime.now().obs;

  Map<String, dynamic>? _originalPayment;
  Map<String, dynamic>? get originalPayment => _originalPayment;

  bool get isEditing => editingPaymentId.value != null;

  @override
  void onInit() {
    super.onInit();
    onGetPaymentList();
  }

  Future<void> onGetPaymentList() async {
    try {
      isLoading.value = true;

      final resp = await service.getPayments();

      if (resp is! List) throw const FormatException('Invalid records');
      paymentList.value = List<Map<String, dynamic>>.from(resp);
      loadError.value = '';
    } catch (e) {
      loadError.value = 'Unable to load payments. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? get selectedSale {
    final saleId = selectedSaleId.value;
    if (saleId == null) return null;
    for (final sale in saleList) {
      if (int.tryParse(sale['id'].toString()) == saleId) return sale;
    }
    return null;
  }

  List<Map<String, dynamic>> get salesWithDue =>
      saleList.where((sale) => parseAmount(sale['due_amount']) > 0).toList();

  double get maxAmount {
    if (isEditing) {
      final originalAmount = parseAmount(_originalPayment?['amount']);
      final refreshedSale = selectedSale;
      final currentDue = refreshedSale != null
          ? parseAmount(refreshedSale['due_amount'])
          : parseAmount(saleMap(_originalPayment?['sale'])['due_amount']);
      return currentDue + originalAmount;
    }
    return parseAmount(selectedSale?['due_amount']);
  }

  void pickPaymentDate(DateTime date) {
    paymentDate.value = date;
  }

  Future<void> addPayment(BuildContext context) async {
    if (isOpeningForm.value) return;
    isOpeningForm.value = true;
    formError.value = '';
    final origin = ModalRoute.of(context);
    try {
      editingPaymentId.value = null;
      _originalPayment = null;
      selectedSaleId.value = null;
      amountCtrl.clear();
      methodCtrl.clear();
      referenceCtrl.clear();
      noteCtrl.clear();
      paymentDate.value = DateTime.now();

      try {
        final resp = await saleService.getSales();
        if (resp is! List) throw const FormatException('Invalid records');
        saleList.value = List<Map<String, dynamic>>.from(resp);
      } catch (e) {
        loadError.value = 'Unable to load sales. Please try again.';
        return;
      }

      if (!context.mounted || (origin != null && !origin.isCurrent)) return;
      await showPaymentForm(context);
    } finally {
      isOpeningForm.value = false;
    }
  }

  Future<void> editPayment(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    if (isOpeningForm.value) return;
    isOpeningForm.value = true;
    formError.value = '';
    final origin = ModalRoute.of(context);
    try {
      _originalPayment = payment;
      editingPaymentId.value = int.tryParse(payment['id'].toString());
      selectedSaleId.value = int.tryParse(
        saleMap(payment['sale'])['id'].toString(),
      );
      amountCtrl.text = payment['amount']?.toString() ?? '';
      methodCtrl.text = payment['payment_method']?.toString() ?? '';
      referenceCtrl.text = payment['reference_no']?.toString() ?? '';
      noteCtrl.text = payment['note']?.toString() ?? '';
      paymentDate.value =
          DateTime.tryParse(
            payment['payment_date']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      // The ceiling comes from the latest balance; a stale list could allow an
      // overpayment after another terminal records a payment.
      try {
        final resp = await saleService.getSales();
        if (resp is! List) throw const FormatException('Invalid records');
        saleList.value = List<Map<String, dynamic>>.from(resp);
      } catch (_) {
        saleList.clear();
        formError.value =
            'Unable to refresh sale balance. Using the recorded balance.';
      }

      if (!context.mounted || (origin != null && !origin.isCurrent)) return;
      await showPaymentForm(context);
    } finally {
      isOpeningForm.value = false;
    }
  }

  Future<void> showPaymentForm(BuildContext context) => AppFormShell.show(
    context,
    isEditing ? const EditPaymentWidget() : const AddPaymentWidget(),
  );

  Future<void> onSavePayment(BuildContext context) async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        !maxAmount.isFinite ||
        amount > maxAmount) {
      return;
    }
    formError.value = '';
    final method = methodCtrl.text.trim();
    final reference = referenceCtrl.text.trim();
    final saleId = selectedSaleId.value;

    isSaving.value = true;
    try {
      if (isEditing) {
        await service.updateSalePayment(editingPaymentId.value!, {
          'amount': amount,
          'payment_method': method,
          'reference_no': reference,
          'payment_date': paymentDate.value.toUtc().toIso8601String(),
          'note': noteCtrl.text.trim(),
        });
        ToastWidget.show(
          message: "Payment updated successfully".tr,
          type: ToastType.success,
        );
      } else {
        await service.createSalePayment({
          'user_id': storage.lastUserLoginRead['user']['id'],
          'sale_id': saleId,
          'amount': amount,
          'payment_method': method,
          'reference_no': reference,
          'payment_date': paymentDate.value.toUtc().toIso8601String(),
          'note': noteCtrl.text.trim(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
        ToastWidget.show(
          message: "Payment created successfully".tr,
          type: ToastType.success,
        );
      }

      SaleListController.invalidateCache();
      await onGetPaymentList();

      if (!context.mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      formError.value = 'Unable to save payment. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onDeletePayment(BuildContext context, int id) async {
    if (!deletingIds.add(id)) return;
    var confirmed = false;
    try {
      await showConfirmDialog(
        context: context,
        message: 'Delete this payment?'.tr,
        onConfirm: () async {
          confirmed = true;
          try {
            await service.deleteSalePayment(id);
            SaleListController.invalidateCache();
            await onGetPaymentList();
            ToastWidget.show(
              message: 'Payment deleted successfully'.tr,
              type: ToastType.success,
            );
          } catch (_) {
            loadError.value = 'Unable to delete payment. Please try again.';
          } finally {
            deletingIds.remove(id);
          }
        },
      );
    } finally {
      if (!confirmed) deletingIds.remove(id);
    }
  }

  @override
  void onClose() {
    searchCtr.onClose();
    amountCtrl.dispose();
    methodCtrl.dispose();
    referenceCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
