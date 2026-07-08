import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
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

  void editCustomer(BuildContext context, Map<String, dynamic> customer){
    AppBottomSheets.show(
      context,
      child: EditCustomerWidget()
    );
  }

  void onDeleteCustomer(int id){
    print("Delete customer with ID: $id");
  }
}