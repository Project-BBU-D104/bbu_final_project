import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/payment/widget/add_payment_widget.dart';
import 'package:frontend/screen/payment/widget/edit_payment_widget.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  PaymentController({SalePaymentService? service, SaleService? saleService})
      : service = service ?? SalePaymentService(),
        saleService = saleService ?? SaleService();

  final SalePaymentService service;
  final SaleService saleService;

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

      if (resp is List) {
        paymentList.value = List<Map<String, dynamic>>.from(resp);
      }
    } catch (e) {
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
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

  List<Map<String, dynamic>> get salesWithDue => saleList
      .where((sale) => parseAmount(sale['due_amount']) > 0)
      .toList();

  double get maxAmount {
    if (isEditing) {
      final originalAmount = parseAmount(_originalPayment?['amount']);
      final refreshedSale = selectedSale;
      final currentDue = refreshedSale != null
          ? parseAmount(refreshedSale['due_amount'])
          : parseAmount(_originalPayment?['sale']?['due_amount']);
      return currentDue + originalAmount;
    }
    return parseAmount(selectedSale?['due_amount']);
  }

  void pickPaymentDate(DateTime date) {
    paymentDate.value = date;
  }

  Future<void> addPayment(BuildContext context) async {
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
      if (resp is List) {
        saleList.value = List<Map<String, dynamic>>.from(resp);
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
      return;
    }

    if (!context.mounted) return;
    AppBottomSheets.show(context, child: AddPaymentWidget());
  }

  Future<void> editPayment(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    _originalPayment = payment;
    editingPaymentId.value = int.tryParse(payment['id'].toString());
    selectedSaleId.value = int.tryParse(
      payment['sale']?['id'].toString() ?? '',
    );
    amountCtrl.text = payment['amount']?.toString() ?? '';
    methodCtrl.text = payment['payment_method']?.toString() ?? '';
    referenceCtrl.text = payment['reference_no']?.toString() ?? '';
    noteCtrl.text = payment['note']?.toString() ?? '';
    paymentDate.value =
        DateTime.tryParse(payment['payment_date']?.toString() ?? '')?.toLocal() ??
            DateTime.now();

    // The ceiling comes from the latest balance; a stale list could allow an
    // overpayment after another terminal records a payment.
    try {
      final resp = await saleService.getSales();
      if (resp is List) {
        saleList.value = List<Map<String, dynamic>>.from(resp);
      }
    } catch (_) {
      // Keep the current list; maxAmount falls back to the nested sale.
    }

    if (!context.mounted) return;
    AppBottomSheets.show(context, child: EditPaymentWidget());
  }

  Future<void> onSavePayment(BuildContext context) async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(amountCtrl.text.trim())!;
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

      await onGetPaymentList();

      if (!context.mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onDeletePayment(BuildContext context, int id) async {
    await showConfirmDialog(
      context: context,
      message: "Delete this payment?".tr,
      onConfirm: () async {
        try {
          await service.deleteSalePayment(id);
          await onGetPaymentList();
          ToastWidget.show(
            message: "Payment deleted successfully".tr,
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
    amountCtrl.dispose();
    methodCtrl.dispose();
    referenceCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
