import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/payment_type/widget/add_payment_type_widget.dart';
import 'package:frontend/screen/payment_type/widget/edit_payment_type_widget.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class PaymentTypeController extends GetxController{
  
  final PaymentTypeService service = PaymentTypeService();
  var isLoading = false.obs;

  final isActive = false.obs;
  final paymentTypeName = TextEditingController();
  final paymentTypeDescription = TextEditingController();
  final paymentTypeList = <Map<String, dynamic>>[].obs;
  final searchPaymentType = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    super.onInit();

    getPaymentTypes();

    final search = Get.put(SearchController());

    ever(
      search.keyword,
      (keyword) {
        searchPaymentTypeList(keyword);
      },
    );
    
  }

  void onClear() {
    paymentTypeName.clear();
    paymentTypeDescription.clear();
    isActive.value = false;
  }

  Future<void> getPaymentTypes() async {
    try{
      isLoading.value = true;
      final resp = await service.getPaymentTypes();
      if(resp is List){

        paymentTypeList.value = List<Map<String, dynamic>>.from(resp);

        searchPaymentType.value = paymentTypeList;
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

  void searchPaymentTypeList(String keyword){
    final search = keyword.trim().toLowerCase();

    if(search.isEmpty){
      searchPaymentType.value = paymentTypeList;
      return;
    }

    searchPaymentType.value = paymentTypeList.where((paymentType) {
      return paymentType["name"].toString().toLowerCase().contains(search);
    }).toList();
  }

  void addPaymentType(BuildContext context) {
    onClear();
    AppBottomSheets.show(
      context,
      child: AddPaymentTypeWidget()
    );
  }

  Future<void> onSavePaymentType() async{
    try{
      isLoading.value = true;

      final data = {
        "name": paymentTypeName.text,
        "description": paymentTypeDescription.text,
        "status": isActive.value,
      };
      
      await service.createPaymentType(data);

      await getPaymentTypes();

      Navigator.pop(Get.context!);

      onClear();

      ToastWidget.show(
        message: "Payment type created successfully",
        type: ToastType.success,
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void editPaymentType(BuildContext context, int paymentTypeId) async{
    try{

      final paymentType = await service.getPaymentTypeById(paymentTypeId);

      paymentTypeName.text = paymentType["name"];
      paymentTypeDescription.text = paymentType["description"];
      isActive.value = paymentType["status"];

      AppBottomSheets.show(
        context,
        child: EditPaymentTypeWidget(
          paymentTypeId: paymentTypeId
        )
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> onUpdatePaymentType(
    int paymentTypeId
  ) async{
    try{
      isLoading.value = true;

      final data = {
        "name": paymentTypeName.text,
        "description": paymentTypeDescription.text,
        "status": isActive.value,
      };

      await service.updatePaymentType(paymentTypeId, data);
      
      await getPaymentTypes();

      Navigator.pop(Get.context!);

      onClear();
      
      ToastWidget.show(
        message: "Payment type updated successfully",
        type: ToastType.success,
      );
    }catch(e){
      // Do nothing
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> onDeletePaymentType(BuildContext context,int paymentTypeId) async{
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this payment type?".tr,
      onConfirm: () async {
        try{
          await service.deletePaymentType(paymentTypeId);

          // Refresh category list
          await getPaymentTypes();

          ToastWidget.show(
            message: "Payment type deleted successfully".tr,
            type: ToastType.success,
          );

          Get.back();

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