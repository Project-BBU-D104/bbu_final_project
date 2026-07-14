// import 'package:flutter/material.dart';
// import 'package:frontend/routes/app_routes.dart';
// import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
// import 'package:frontend/services/main_service/purchase_service.dart';
// import 'package:frontend/widget/bottom_sheets.dart';
// import 'package:frontend/widget/toast_widget.dart';
// import 'package:get/get.dart';

// class PurchaseController extends GetxController{
//   final PurchaseService service = PurchaseService();
//   var isLoading = false.obs;
//   final purchaseList = <Map<String, dynamic>> [].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     onGetPurchaseList();
//   }
  
//   Future<void> onGetPurchaseList() async{
//     try{
//       isLoading.value = true;

//       final resp = await service.getPurchases();

//       if(resp is List){
//         purchaseList.value = List<Map<String, dynamic>>.from(resp);
//       }

//       print(purchaseList);
//     }catch(e){
//       ToastWidget.show(
//         message: e.toString(),
//         type: ToastType.error,
//       );
//     }finally{
//       isLoading.value = false;
//     }
//   }


//   void addPurchase(BuildContext context){
//     AppBottomSheets.show(
//       context,
//       child: AddPurchaseWidget()
//     );
//   }

//   void gotoPurchaseDetail(Map<String, dynamic> purchase){
//     Get.toNamed(AppRoutes.purchaseDetail, arguments: purchase);
//   }

//   void editPurchase(BuildContext context, Map<String, dynamic> purchase){
//     // AppBottomSheets.show(
//     //   context,
//     //   child: EditPurchaseWidget(purchase: purchase)
//     // );
//   }

//   void deletePurchase(int purchaseId){
//     // Implement the logic to delete the purchase with the given purchaseId
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:frontend/services/main_service/purchase_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController {
  final PurchaseService service = PurchaseService();
  var isLoading = false.obs;
  final purchaseList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    onGetPurchaseList();
  }

  Future<void> onGetPurchaseList() async {
    try {
      isLoading.value = true;

      final resp = await service.getPurchases();

      if (resp is List) {
        purchaseList.value = List<Map<String, dynamic>>.from(resp);
      }

      print(purchaseList);
    } catch (e) {
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addPurchase(BuildContext context) {
    resetForm();
    AppBottomSheets.show(
      context,
      child: AddPurchaseWidget(),
    );
  }

  void gotoPurchaseDetail(Map<String, dynamic> purchase) {
    Get.toNamed(AppRoutes.purchaseDetail, arguments: purchase);
  }

  void editPurchase(BuildContext context, Map<String, dynamic> purchase) {
    // AppBottomSheets.show(
    //   context,
    //   child: EditPurchaseWidget(purchase: purchase)
    // );
  }

  void deletePurchase(int purchaseId) {
    // Implement the logic to delete the purchase with the given purchaseId
  }

  // ================= Add Purchase Form State =================

  final formKey = GlobalKey<FormState>();
  final invoiceCtrl = TextEditingController();
  final taxCtrl = TextEditingController(text: '0');
  final discountCtrl = TextEditingController(text: '0');
  final paidCtrl = TextEditingController(text: '0');

  // Adjust to your Supplier model — assumed Map<String,dynamic> like purchaseList.
  final Rxn<Map<String, dynamic>> selectedSupplier = Rxn<Map<String, dynamic>>();
  final Rx<DateTime> purchaseDate = DateTime.now().obs;

  final RxList<PurchaseItemForm> items = <PurchaseItemForm>[].obs;

  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble paid = 0.0.obs;

  var isSaving = false.obs;

  double get itemsSubtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total =>
      (itemsSubtotal + tax.value - discount.value).clamp(0, double.infinity);

  double get due => (total - paid.value).clamp(0, double.infinity);

  PurchaseController() {
    taxCtrl.addListener(() => tax.value = double.tryParse(taxCtrl.text) ?? 0);
    discountCtrl.addListener(
        () => discount.value = double.tryParse(discountCtrl.text) ?? 0);
    paidCtrl.addListener(() => paid.value = double.tryParse(paidCtrl.text) ?? 0);
  }

  void resetForm() {
    invoiceCtrl.clear();
    taxCtrl.text = '0';
    discountCtrl.text = '0';
    paidCtrl.text = '0';
    tax.value = 0;
    discount.value = 0;
    paid.value = 0;
    selectedSupplier.value = null;
    purchaseDate.value = DateTime.now();

    for (final i in items) {
      i.dispose();
    }
    items
      ..clear()
      ..add(PurchaseItemForm());
  }

  void pickPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  void addItemRow() {
    items.add(PurchaseItemForm());
  }

  void removeItemRow(PurchaseItemForm item) {
    if (items.length == 1) return; // keep at least one row
    item.dispose();
    items.remove(item);
  }

  Future<void> createPurchase(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedSupplier.value == null) {
      ToastWidget.show(message: 'Please select a supplier', type: ToastType.error);
      return;
    }

    final invalidRow = items.any(
      (i) => i.product.value == null || i.qty.value <= 0 || i.cost.value <= 0,
    );
    if (invalidRow) {
      ToastWidget.show(
        message: 'Fill in product, qty and cost for every item',
        type: ToastType.error,
      );
      return;
    }

    final payload = {
      'supplier_id': selectedSupplier.value!['id'],
      'invoice_no': invoiceCtrl.text.trim(),
      'purchase_date': purchaseDate.value.toIso8601String(),
      'subtotal': itemsSubtotal,
      'tax_amount': tax.value,
      'discount_amount': discount.value,
      'total_amount': total,
      'paid_amount': paid.value,
      'due_amount': due,
      'payment_status':
          due <= 0 ? 'paid' : (paid.value > 0 ? 'partial' : 'unpaid'),
      'items': items
          .map((i) => {
                'product_id': i.product.value!['id'],
                'qty': i.qty.value,
                'cost_price': i.cost.value,
                'subtotal': i.subtotal,
              })
          .toList(),
    };

    try {
      isSaving.value = true;
      // Add `createPurchase` to PurchaseService, e.g.:
      // Future<dynamic> createPurchase(Map<String, dynamic> data) => post('/purchases', data);
      await service.createPurchase(payload);

      await onGetPurchaseList();
      ToastWidget.show(message: 'Purchase added', type: ToastType.success);
      Navigator.pop(context);
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    invoiceCtrl.dispose();
    taxCtrl.dispose();
    discountCtrl.dispose();
    paidCtrl.dispose();
    for (final i in items) {
      i.dispose();
    }
    super.onClose();
  }
}