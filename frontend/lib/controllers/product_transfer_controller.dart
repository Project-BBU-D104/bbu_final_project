import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class ProductTransferController extends GetxController{
 
  var isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final ProductTransferService service = ProductTransferService();
  final stockTransfer = <Map<String, dynamic>>[].obs;
  final RxnInt selectedFromWarehouse = RxnInt();
  final RxnInt selectedToWarehouse = RxnInt();
  final RxnInt selectedProduct = RxnInt();
  final RxnInt quantity = RxnInt();
  final quantityController = TextEditingController();
  final productTransferRefController = TextEditingController();
  final productTransferDate = TextEditingController();

  final Rxn<Map<String, dynamic>> editingTransfer = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    onGetProductTransferList();
    super.onInit();
  }

  void onClear(){
      selectedFromWarehouse.value = null;
      selectedToWarehouse.value = null;
      selectedProduct.value = null;
      quantity.value = null;
      productTransferDate.clear();
      productTransferRefController.clear();
      quantityController.clear();
  }

  Future<void> onGetProductTransferList() async{
    try{
      isLoading.value = true;

      final resp = await service.getProductTransfers();

      if(resp is List){
        stockTransfer.value = List<Map<String, dynamic>>.from(resp);
      }
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate.value,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    selectedDate.value = picked;
  }
}

  String get formattedDate {
  return selectedDate.value.toString().split(" ")[0];
}

  void addStockTransfer(BuildContext context){
    onClear();
    AppBottomSheets.show(
      context,
      child: AddStockTransferWidget()
    );
  }

  Future<void> onSaveStockTransfer(BuildContext context) async{
    try{
      isLoading.value = true;

      final data = {
        "from_warehouse_id": selectedFromWarehouse.value,
        "to_warehouse_id": selectedToWarehouse.value,
        "product_id": selectedProduct.value,
        "reference_no": productTransferRefController.text.trim(),  
        "qty": quantity.value,
        "transfer_date": formattedDate
      };

      await service.createProductTransfer(data);

      ToastWidget.show(
        message: "Stock transfer created successfully",
        type: ToastType.success,
      );

      // Reload Product Transfer
      await onGetProductTransferList();

      // Close BottomSheet
      Navigator.pop(context);

      // Clear textfields
      onClear();

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void gotoStockTransferDetail(Map<String, dynamic> stockTransfer){
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
  }

  void editStockTransfer(
  BuildContext context,
  Map<String, dynamic> stockTransfer,
) async {
  try {
    final transfer = await service.getProductTransferById(
      stockTransfer["id"],
    );

    editingTransfer.value = stockTransfer;


    selectedFromWarehouse.value =
        transfer["from_warehouse"]["id"];

    selectedToWarehouse.value =
        transfer["to_warehouse"]["id"];

    selectedProduct.value =
        transfer["product"]["id"];

    quantity.value = transfer["qty"];
    quantityController.text = transfer["qty"].toString();
    productTransferRefController.text = transfer["reference_no"];
    productTransferDate.text = transfer["transfer_date"];

    AppBottomSheets.show(
      context,
      child: EditStockTransferWidget(),
    );
  } catch (e) {
    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );
  }
}

  Future<void> onUpdate(
  BuildContext context,
  Map<String, dynamic> stockTransfer
) async {
  try {
    isLoading.value = true;

    final data = {
      "from_warehouse_id": selectedFromWarehouse.value,
      "to_warehouse_id": selectedToWarehouse.value,
      "product_id": selectedProduct.value,
      "reference_no": productTransferRefController.text.trim(),
      "qty": quantity.value,
      "transfer_date": formattedDate
    };

    await service.updateProductTransfer(
      stockTransfer["id"],
      data,
    );
    ToastWidget.show(
      message: "Stock transfer updated successfully",
      type: ToastType.success,
    );

    await onGetProductTransferList();

    // Close BottomSheet
    Navigator.pop(context);

    onClear();
  } catch(e) {

    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );

  } finally {

    isLoading.value = false;

  }
}

  void onDeleteStockTransfer(BuildContext context,int productTransferId) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this stock transfer?".tr,
      onConfirm: () async {
        try{
          await service.deleteProductTransfer(productTransferId);

          // Refresh category list
          await onGetProductTransferList();

            Get.back();

          ToastWidget.show(
            message: "Stock transfer deleted successfully".tr,
            type: ToastType.success,
          );

        }catch(e){
          ToastWidget.show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}