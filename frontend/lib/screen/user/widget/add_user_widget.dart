import 'package:flutter/material.dart';
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add User",
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

          DropdownButtonFormField<String>(
            value: ctr.selectedUser.value,
            decoration: const InputDecoration(
              hintText: "Select User Type",
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

          Text("Username", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Password",
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
              const Text("Disable User"),
            ],
          );
        }),

          const SizedBox(height: 15),

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