import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ChangePasswordWidget extends StatelessWidget {
  ChangePasswordWidget({super.key});

  final ctr = Get.find<ProfileController>();

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
        key: ctr.passwordFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Change Password".tr,
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
                controller: ctr.currentPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Current Password".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true)
                    ? "Current password is required".tr
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.newPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value?.length ?? 0) < 8) {
                    return "Password must be at least 8 characters".tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ctr.confirmPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm New Password".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value != ctr.newPasswordCtrl.text
                        ? "Passwords do not match".tr
                        : null,
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
                        : () => ctr.onChangePassword(context),
                    child: Text(
                      ctr.isSaving.value
                          ? "Saving...".tr
                          : "Update Password".tr,
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
