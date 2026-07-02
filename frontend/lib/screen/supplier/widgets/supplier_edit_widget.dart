import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';

class SupplierEditWidget extends StatelessWidget {
  SupplierEditWidget({super.key});

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
              Text(
                "Edit Supplier".tr,
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

          Text("Supplier Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Supplier Name".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Phone Number".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Phone Number".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Email".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Email".tr,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Map".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Enter Map".tr,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text("Address".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Enter Address".tr,
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
                Navigator.pop(context);
              },
              child: Text("Save".tr, 
                style: TextStyle(fontSize: 18)
              ),
            ),
          ),
        ],
      ),
    );
  }
}