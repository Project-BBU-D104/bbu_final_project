import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:get/get.dart';

class EditProfileWidget extends StatelessWidget {
  EditProfileWidget({super.key});

  final ctr = Get.find<ProfileController>();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? requiredField(String? value, String message) {
    return (value?.trim().isEmpty ?? true) ? message : null;
  }

  String? validEmail(String? value) {
    final email = value?.trim() ?? '';
    return _emailPattern.hasMatch(email) ? null : "Enter a valid email".tr;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Form(
        key: ctr.profileFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.nameCtrl,
                decoration: InputDecoration(
                  labelText: "Full Name".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    requiredField(value, "Name is required".tr),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: validEmail,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number".tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.photoCtrl,
                decoration: InputDecoration(
                  labelText: "Photo URL".tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: ctr.isSaving.value
                        ? null
                        : () => ctr.onUpdateProfile(context),
                    child: Text(
                      ctr.isSaving.value ? "Saving...".tr : "Save".tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
