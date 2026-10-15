import 'package:flutter/material.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/screen/purchase_payment/widget/add_purchase_payment_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentController extends GetxController {
  final PurchasePaymentService service = PurchasePaymentService();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final purchasePaymentList = <Map<String, dynamic>>[].obs;

  final purchaseCtr = Get.put(PurchaseController());
  final paymentTypeCtr = Get.put(PaymentTypeController());
  final currencyCtr = Get.put(CurrencyController());

  final formKey = GlobalKey<FormState>();
  final paymentNoCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final selectedPaymentTypeId = RxnInt();
  final selectedCurrencyId = RxnInt();
  final selectedPurchaseId = RxnInt();
  final paymentStatus = "completed".obs;

  final Rx<DateTime> purchaseDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    onGetPaymentList();
  }

  Future<void> onGetPaymentList() async {
    try {
      isLoading.value = true;

      final resp = await service.getPurchasePayments();

      if (resp is List) {
        purchasePaymentList.value = List<Map<String, dynamic>>.from(resp);
      }

      // print(purchasePaymentList);
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
      double.tryParse(selectedPurchase?["due_amount"].toString() ?? "") ?? 0;

  Future<void> onSavePurchasePayment(BuildContext context) async {
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
      "payment_date": purchaseDate.value.toIso8601String(),
      "status": paymentStatus.value,
      "note": noteCtrl.text.trim(),
    };

    try {
      isSaving.value = true;
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

  @override
  void onClose() {
    paymentNoCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
