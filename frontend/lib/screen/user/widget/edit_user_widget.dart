import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/controllers/role_controller.dart';

class EditUserWidget extends StatelessWidget {

  final int userId;

  EditUserWidget({
    super.key,
    required this.userId,
  });

  final ctr = Get.find<UserController>();
  final roleCtr = Get.put(RoleController());
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(

        child: Form(
          key: ctr.key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          
            children: [
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
                children: [
          
                  Text(
                    "Edit User".tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  )
          
                ],
              ),
          
              ImageUploadWidget(
                bucket: "user",
                folder: "users",
                imageUrl: ctr.userPhotoController.text,
                onUploaded: (url){
                  ctr.userPhotoController.text = url;
                },
              ),
              const SizedBox(height: 15),
              Text(
                "Role".tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
             Obx(() {
              return DropdownButtonFormField<String>(
                value: roleCtr.roleList.any(
                  (role) =>
                      role["id"].toString() == ctr.selectedRole.value,
                )
                    ? ctr.selectedRole.value
                    : null,
                decoration: InputDecoration(
                  hintText: "Select Role".tr,
                  border: const OutlineInputBorder(),
                ),
                items: roleCtr.roleList.map((role){
                  return DropdownMenuItem<String>(
                    value: role["id"].toString(),
                    child: Text(
                      role["name"],
                    ),
                  );
                }).toList(),
                onChanged: (value){
                  ctr.selectedRole.value = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a role".tr;
                  }
                  return null;
                },
              );
            }),
              const SizedBox(height: 10),
              Text(
                "System Configuration".tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Obx(() {
                if (ctr.systemConfigurationCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return DropdownButtonFormField<String>(
                  value: ctr.systemConfigurationCtr.systemConfigurationList.any(
                    (configuration) =>
                        configuration["id"].toString() ==
                        ctr.selectedSystemConfiguration.value,
                  )
                      ? ctr.selectedSystemConfiguration.value
                      : null,
                  decoration: InputDecoration(
                    hintText: "Select System Configuration".tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: ctr.systemConfigurationCtr.systemConfigurationList.map((configuration){
                    return DropdownMenuItem<String>(
                      value: configuration["id"].toString(),
                      child: Text(
                        configuration["company_name"] ?? "",
                      ),
                    );
                  }).toList(),
                  onChanged: (value){
                    ctr.selectedSystemConfiguration.value = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a system configuration".tr;
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 10),
              _field(
                title: "Username",
                controller: ctr.userNameController,
                hint: "Enter Username",
                required: true,
              ),
          
              _field(
                title: "Email",
                controller: ctr.userEmailController,
                hint: "Enter Email",
              ),
              _field(
                title: "Phone Number",
                controller: ctr.userPhoneController,
                hint: "Enter Phone Number",
              ),
          
              _field(
                title: "Password",
                controller: ctr.userPasswordController,
                hint: "Enter Password",
                isPassword: true,
              ),
          
              const SizedBox(height: 10),
              Obx(() {
                return Row(
                  children: [
                    Checkbox(
                      value: ctr.isChecked.value,
                      onChanged: (value){
                        ctr.isChecked.value = value ?? false;
                      },
                    ),
          
                    Text(
                      "Disable User".tr,
                    )
                  ],
                );
              }),
          
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                  ),
          
                  onPressed: () async {
                    if(ctr.key.currentState?.validate() ?? false){
                    await ctr.onUpdateUser(
                      userId,
                      context,
                    );
                  }},
          
                  child: Text(
                    "Update".tr,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
          
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

 Widget _field({
  required String title,
  required TextEditingController controller,
  required String hint,
  bool required = false,
  bool isEmail = false,
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title.tr,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),

      const SizedBox(height: 5),

      TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint.tr,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return "Please enter $title".tr;
          }

          if (isEmail &&
              value != null &&
              value.trim().isNotEmpty &&
              !GetUtils.isEmail(value.trim())) {
            return "Please enter a valid email".tr;
          }

          return null;
        },
      ),

      const SizedBox(height: 10),
    ],
  );
}
}