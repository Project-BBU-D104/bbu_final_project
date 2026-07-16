import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController{
  final customerList = <Map<String, dynamic>>[].obs;

  final CustomerService service = CustomerService();
  
  var isLoading = false.obs;

  final customerPhotoController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneNumberController = TextEditingController();
  final customerAddressController = TextEditingController();
  final isActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCustomers();
  }

  @override
  void onClose() {
    customerPhotoController.dispose();
    customerNameController.dispose();
    customerPhoneNumberController.dispose();
    customerAddressController.dispose();
    super.onClose();
  }

  Future<void> getCustomers() async{
    try{
      isLoading.value = true;

      final resp = await service.getCustomers();

      if (resp is List) {
        customerList.value = List<Map<String, dynamic>>.from(resp);
      }
    }catch(e){
      // 
    }
    finally{
      isLoading.value = false;
    }
  }

  void addCustomer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddCustomerWidget()
    );
  }

  Future<void> onSaveCustomer(BuildContext context) async{
    try{
      isLoading.value = true;

      final data = {
        "photo": customerPhotoController.text.trim(),
        "name": customerNameController.text.trim(),
        "phone": customerPhoneNumberController.text.trim(),
        "address": customerAddressController.text.trim(),
        "is_active": isActive.value
      };

      await service.createCustomer(data);

      ToastWidget.show(
        message: "Category created successfully",
        type: ToastType.success,
      );

      // Reload Category
    await getCustomers();

    // Clear textfields
    customerPhotoController.clear();
    customerNameController.clear();
    customerPhoneNumberController.clear();
    customerAddressController.clear();

    isActive.value = false;

    Get.find<ImageUploadController>()
    .clearImage();

    // Close BottomSheet
    Navigator.pop(context);

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> editCustomer(BuildContext context, int customerId) async{
    try{

      final customer = await service.getCustomerById(customerId);

      customerPhotoController.text = customer["photo"] ?? "";
      customerNameController.text = customer["name"] ?? "";
      customerPhoneNumberController.text = customer["phone"] ?? "";
      customerAddressController.text = customer["address"] ?? "";

      AppBottomSheets.show(
      context,
      child: EditCustomerWidget(
        customerId: customer["id"],
      )
    );
    }catch(e){
      // do it
    }
  }

  Future<void> onUpdateCustomer(int customerId, BuildContext context) async{
    try{
      final data = {
        "photo": customerPhotoController.text.trim(),
        "name": customerNameController.text.trim(),
        "phone": customerPhoneNumberController.text.trim(),
        "address": customerAddressController.text.trim(),
      };

      await service.updateCustomer(customerId, data);

      // Reload Category
      await getCustomers();

      // Clear textfields
      customerPhotoController.clear();
      customerNameController.clear();
      customerPhoneNumberController.clear();
      customerAddressController.clear();

      Get.find<ImageUploadController>()
      .clearImage();

      // Close BottomSheet
      Navigator.pop(context);

      ToastWidget.show(
        message: "Customer updated successfully",
        type: ToastType.success,
      );
      
    }catch(e){
      // 
    }
  }

  void onDeleteCustomer(int customerId , BuildContext context){
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this customer?".tr,
      onConfirm: () async {
        try{
          await service.deleteCustomer(customerId);
          // Refresh category list
          await getCustomers();

          ToastWidget.show(
            message: "Customer deleted successfully".tr,
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