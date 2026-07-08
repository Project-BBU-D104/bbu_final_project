import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';

class EditCustomerWidget extends StatelessWidget {
  final int customerId;
  EditCustomerWidget({super.key, required this.customerId});

  final ctr = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Customer".tr,
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
        
            ImageUploadWidget(
              imageUrl: ctr.customerPhotoController.text,
              onUploaded: (url) {
                ctr.customerPhotoController.text = url;
              },
            ),
      
            const SizedBox(height: 10),
      
            Text("Customer Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.customerNameController,
              decoration: InputDecoration(
                hintText: "Enter Customer Name".tr,
                border: OutlineInputBorder(),
              ),
            ),
      
            const SizedBox(height: 10),
            Text("Phone Number".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.customerPhoneNumberController,
              decoration: InputDecoration(
                hintText: "Enter Phone Number".tr,
                border: OutlineInputBorder(),
              ),
            ),
      
            const SizedBox(height: 10),
            Text("Address".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
             TextField(
                maxLines: 8,
                minLines: 3,
                controller: ctr.customerAddressController,
                decoration: InputDecoration(
                  hintText: "Enter Address".tr,
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
                  foregroundColor: titleColor,
                ),
                onPressed: () {
                  ctr.onUpdateCustomer(customerId, context);
                },
                child: Text("Update".tr, style: TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}