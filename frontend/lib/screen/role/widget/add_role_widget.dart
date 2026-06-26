import 'package:flutter/material.dart';
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 200,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Role",
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

          const TextField(
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),

         

          const SizedBox(height: 10),

          SizedBox(
            height: 120,
            child: const TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: ctr.isChecked.value,
                onChanged: (value) {
                  ctr.isChecked.value = value!;
                },
              ),
              const Text("Accept Terms & Conditions"),
            ],
          );
        }),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}