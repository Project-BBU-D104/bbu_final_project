import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:get/get.dart';

class AddRoleWidget extends StatelessWidget {
  AddRoleWidget({super.key});

  final ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Role".tr,
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

          const SizedBox(height: 10),

          Text("Role Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            controller: ctr.roleNameController,
            decoration: InputDecoration(
              hintText: "Enter Role Name".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Description".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            maxLines: 8,
            minLines: 3,
            controller: ctr.roleDescriptionController,
            decoration: InputDecoration(
              hintText: "Enter Description".tr,
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 10),

          Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: ctr.isActive.value,
                onChanged: (value) {
                  ctr.isActive.value = value!;
                },
              ),
              Text("Status".tr),
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
                ctr.onSaveRole();
              },
              child: Text("Save".tr,
              style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}