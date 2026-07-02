import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:get/get.dart';

class AddUserWidget extends StatelessWidget {
  AddUserWidget({super.key});

  final ctr = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
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
                  fontSize: 18,
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

          
          Text("Role".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: ctr.selectedUser.value,
            decoration: InputDecoration(
              hintText: "Select User Type".tr,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: const [
              DropdownMenuItem(
                value: "admin",
                child: Text("Admin"),
              ),
              DropdownMenuItem(
                value: "cashier",
                child: Text("Cashier"),
              ),
            ],
            onChanged: (value) {
              ctr.selectedUser.value = value ?? '';
            },
          ),
          
          const SizedBox(height: 10),
          Text("Username".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Username".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Email".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Email".tr,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Password".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Password".tr,
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
                Navigator.pop(context);
              },
              child: Text("Save".tr, style: TextStyle(fontSize: 18),),
            ),
          ),
        ],
      ),
    );
  }
}