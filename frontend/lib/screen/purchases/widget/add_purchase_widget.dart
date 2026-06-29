import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase_controller.dart';
import 'package:get/get.dart';

class AddPurchaseWidget extends StatelessWidget {
  AddPurchaseWidget({super.key});

  final ctr = Get.find<PurchaseController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Purchase",
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

          Text("Role Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: "Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
          Text("Description", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5),
          TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Description",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 10),

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