import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class CustomerController extends GetxController{

  final customerList = <Map<String, dynamic>>[].obs;
  final CustomerService service = CustomerService();
  var isLoading = false.obs;
  final customerPhotoController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneNumberController = TextEditingController();
  final customerAddressController = TextEditingController();
  final isActive = false.obs;
  final searchCustomerList = <Map<String, dynamic>>[].obs;  
  
  @override
  void onInit() {
    super.onInit();
    getCustomers();

    final search = Get.put(SearchController());

    ever(
      search.keyword,
      (keyword) {
        searchCustomer(keyword);
      },
    );
  }

  @override
  void onClose() {
    customerPhotoController.dispose();
    customerNameController.dispose();
    customerPhoneNumberController.dispose();
    customerAddressController.dispose();
    super.onClose();
  }

  void clearCustomer(){
    customerPhotoController.clear();
    customerNameController.clear();
    customerPhoneNumberController.clear();
    customerAddressController.clear();
  }

  Future<void> getCustomers() async{
    try{
      isLoading.value = true;
      final resp = await service.getCustomers();
      if (resp is List) {

        customerList.value = List<Map<String, dynamic>>.from(resp);
        // For Search
        searchCustomerList.value = customerList;
      }
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
    finally{
      isLoading.value = false;
    }
  }

  void searchCustomer(String keyword){

    final search = keyword.trim().toLowerCase();
    if(search.isEmpty){
      searchCustomerList.value = customerList;
      return;
    }

    searchCustomerList.value = customerList.where((customer) {
      return (customer["name"] ?? "").toString().toLowerCase().contains(search);
    }).toList();
  }

  void addCustomer(BuildContext context){
    clearCustomer();
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
        message: "Customer created successfully",
        type: ToastType.success,
      );

      // Reload Customer
    await getCustomers();

    // Clear textfields
    clearCustomer();

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

      isActive.value = customer["is_active"] ?? false;

      AppBottomSheets.show(
      context,
      child: EditCustomerWidget(
        customerId: customer["id"],
      )
    );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> onUpdateCustomer(int customerId, BuildContext context) async{
    try{
      final data = {
        "photo": customerPhotoController.text.trim(),
        "name": customerNameController.text.trim(),
        "phone": customerPhoneNumberController.text.trim(),
        "address": customerAddressController.text.trim(),
        "is_active": isActive.value
      };

      await service.updateCustomer(customerId, data);
      // Reload Customer
      await getCustomers();
      // Clear textfields
      clearCustomer();
      Get.find<ImageUploadController>()
      .clearImage();

      // Close BottomSheet
      Navigator.pop(context);

      ToastWidget.show(
        message: "Customer updated successfully",
        type: ToastType.success,
      );
      
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  void onDeleteCustomer(int customerId , BuildContext context){
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this customer?".tr,
      onConfirm: () async {
        try{
          await service.deleteCustomer(customerId);
          // Refresh customer list
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