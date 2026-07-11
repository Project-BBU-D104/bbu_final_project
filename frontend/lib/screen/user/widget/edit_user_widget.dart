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
                    fontSize: 18,
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
            );
          }),
            const SizedBox(height: 10),
            _field(
              title: "Username",
              controller: ctr.userNameController,
              hint: "Enter Username",
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
                  await ctr.onUpdateUser(
                    userId,
                    context,
                  );
                },

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
    );
  }

  Widget _field({
    required String title,
    required TextEditingController controller,
    required String hint,
  }){
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

        const SizedBox(height:5),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height:10),
      ],
    );
  }
}