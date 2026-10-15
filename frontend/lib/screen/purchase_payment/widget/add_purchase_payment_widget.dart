import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:get/get.dart';

class AddPurchasePaymentWidget extends StatelessWidget {
  AddPurchasePaymentWidget({super.key});

  final ctr = Get.find<PurchasePaymentController>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
      Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ctr.purchaseDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) ctr.pickPurchaseDate(picked);
  }
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Purchase Payment".tr,  
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
        
            Text(
              "Select Purchase".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        
            SizedBox(height: 10),
        
           Obx(() {
              
            if (ctr.purchaseCtr.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            if (ctr.purchaseCtr.purchaseList.isEmpty) {
              return Center(
                child: Text("No Purchase Found".tr),
              );
            }
        
          // Filter purchases that still have an outstanding balance
          final selectDuePurchase = ctr.purchaseCtr.purchaseList
            .where((purchase) =>
                (double.tryParse(purchase['due_amount'].toString()) ?? 0) > 0)
            .toList();
        
            return DropdownButtonFormField<String>(
              value: ctr.selectedPurchase.value,
        
              decoration: InputDecoration(
                hintText: "Select Purchase".tr,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
        
              items: selectDuePurchase.map((purchase) {
                return DropdownMenuItem<String>(
                  value: purchase['id'].toString(),
                  child: Text(
                    "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
                  ),
                );
              }).toList(),
        
              onChanged: (value) {
                ctr.selectedPurchase.value = value;
              },
            );
          }),
        
            const SizedBox(height: 10),
        
            Text(
              "Select Payment Date".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Obx(() => InkWell(
                    onTap: () => _pickDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      child: Text(
                        "${ctr.purchaseDate.value.year}-"
                        "${ctr.purchaseDate.value.month.toString().padLeft(2, '0')}-"
                        "${ctr.purchaseDate.value.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  )),
            const SizedBox(height: 10),
            Text(
              "Select Payment Type".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        
            SizedBox(height: 10),
        
           Obx(() {
              
            if (ctr.purchaseCtr.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            if (ctr.purchaseCtr.purchaseList.isEmpty) {
              return Center(
                child: Text("No Purchase Found".tr),
              );
            }
        
          // Filter purchases that still have an outstanding balance
          final selectDuePurchase = ctr.purchaseCtr.purchaseList
            .where((purchase) =>
                (double.tryParse(purchase['due_amount'].toString()) ?? 0) > 0)
            .toList();
        
            return DropdownButtonFormField<String>(
              value: ctr.selectedPurchase.value,
        
              decoration: InputDecoration(
                hintText: "Select Purchase".tr,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
        
              items: selectDuePurchase.map((purchase) {
                return DropdownMenuItem<String>(
                  value: purchase['id'].toString(),
                  child: Text(
                    "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
                  ),
                );
              }).toList(),
        
              onChanged: (value) {
                ctr.selectedPurchase.value = value;
              },
            );
          }),
            const SizedBox(height: 10),
            Text(
              "Select Currency".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        
            SizedBox(height: 10),
        
           Obx(() {
              
            if (ctr.purchaseCtr.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            if (ctr.purchaseCtr.purchaseList.isEmpty) {
              return Center(
                child: Text("No Purchase Found".tr),
              );
            }
        
          // Filter purchases that still have an outstanding balance
          final selectDuePurchase = ctr.purchaseCtr.purchaseList
            .where((purchase) =>
                (double.tryParse(purchase['due_amount'].toString()) ?? 0) > 0)
            .toList();
        
            return DropdownButtonFormField<String>(
              value: ctr.selectedPurchase.value,
        
              decoration: InputDecoration(
                hintText: "Select Purchase".tr,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
        
              items: selectDuePurchase.map((purchase) {
                return DropdownMenuItem<String>(
                  value: purchase['id'].toString(),
                  child: Text(
                    "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
                  ),
                );
              }).toList(),
        
              onChanged: (value) {
                ctr.selectedPurchase.value = value;
              },
            );
          }),
        
            const SizedBox(height: 10),
        
            Text("Amount".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
              SizedBox(height: 5),
              TextFormField(
                // controller: ctr.customerNameController,
                decoration: InputDecoration(
                  hintText: "Enter Amount".tr,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Customer name is required".tr;
                  }
                  return null;
                },
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
      ),
    );
  }
}