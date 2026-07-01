import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';

class SupplierAddWidget extends StatelessWidget {
  SupplierAddWidget({super.key});

  final ctr = Get.find<SupplierController>();

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
              const Text(
                "Add Supplier",
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

          Text("Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            decoration: InputDecoration(
              hintText: "Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Phone", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            decoration: InputDecoration(
              hintText: "Phone",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Map", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Map",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Address",
              border: OutlineInputBorder(),
            ),
          ),
           
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
              const Text("Status"),
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
              child: const Text("Save", 
                style: TextStyle(fontSize: 18)
              ),
            ),
          ),
        ],
      ),
    );
  }
}