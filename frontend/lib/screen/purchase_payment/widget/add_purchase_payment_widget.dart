import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:get/get.dart';

class AddPurchasePaymentWidget extends StatelessWidget {
  AddPurchasePaymentWidget({super.key});

  final ctr = Get.find<PurchasePaymentController>();

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
                "Add Category".tr,
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

          Text("Category Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            // controller: ctr.nameController,
            decoration: InputDecoration(
              hintText: "Enter Category Name".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Description".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            maxLines: 8,
            minLines: 3,
            // controller: ctr.descriptionController,
            decoration: InputDecoration(
              hintText: "Enter Description".tr,
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
 

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                 
              ),
              onPressed: () {
                // ctr.onSaveCategory(context);
              },
              child: Text(
                "Save".tr,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
              )
            ),
          ),
        ],
      ),
    );
  }
}