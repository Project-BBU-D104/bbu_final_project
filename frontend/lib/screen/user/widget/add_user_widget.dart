import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';

class AddUserWidget extends StatelessWidget {
  AddUserWidget({super.key});

  final ctr = Get.put(UserController());
  final roleCtr = Get.put(RoleController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add User".tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
        
        
            const SizedBox(height: 10),
        
            ImageUploadWidget(
              bucket: "user",
              folder: "users",
                onUploaded: (url) {
                  ctr.userPhotoController.text = url;
                },
            ),
        
            const SizedBox(height: 10),
        
            
            Text("Role".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            Obx(() {

              if(roleCtr.isLoading.value){

                return const Center(
                  child: CircularProgressIndicator(),
                );

              }
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: roleCtr.roleList.map((role){
                  return DropdownMenuItem<String>(
                    value: role["id"].toString(),
                    child: Text(
                      role["name"] ?? "",
                    ),
                  );
                }).toList(),

                onChanged: (value){
                  ctr.selectedRole.value = value;
                },
              );
            }),
            
            const SizedBox(height: 10),
            Text("Username".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.userNameController,
              decoration: InputDecoration(
                hintText: "Enter Username".tr,
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 10),
            Text("Email".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.userEmailController,
              decoration: InputDecoration(
                hintText: "Enter Email".tr,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text("Password".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.userPasswordController,
              decoration: InputDecoration(
                hintText: "Enter Password".tr,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text("Phone Number".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.userPhoneController,
              decoration: InputDecoration(
                hintText: "Enter Phone Number".tr,
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 10),
        
            Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: ctr.isChecked.value,
                  onChanged: (value) {
                    ctr.isChecked.value = value!;
                  },
                ),
                Text("Disable User".tr),
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
                onPressed: () {
                  ctr.onSaveUser(context);
                },
                child: Text("Save".tr, style: TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}