import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var isEditMode = false.obs;

  var name = ''.obs;
  var phone = ''.obs;
  var email = ''.obs;
  var address = ''.obs;
  var photoPath = ''.obs;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  void pickPhoto() {
    photoPath.value = "uploads/supplier_profile.png";
    print("Photo selected: ${photoPath.value}");
  }

  void cancelAction() {
    Get.back();
  }

  void saveAction() {
    if (formKey.currentState!.validate()) {
      if (isEditMode.value) {
        print("Updating Supplier");
        print("Name: ${nameCtrl.text}");
        print("Phone: ${phoneCtrl.text}");
        print("Email: ${emailCtrl.text}");
        print("Address: ${addressCtrl.text}");
        print("Photo Path: ${photoPath.value}");
      } else {
        print("Inserting New Supplier");
        print("Name: ${name.value}");
        print("Phone: ${phone.value}");
        print("Email: ${email.value}");
        print("Address: ${address.value}");
        print("Photo Path: ${photoPath.value}");

        String createdAt = DateTime.now().toString();
        int createdBy = 1;

        print("Created At (Auto Generated): $createdAt");
        print("Created By (Auto Generated User ID): $createdBy");
      }
      Get.back();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }
}
