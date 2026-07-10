import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:get/get.dart';

class EditStockTransferWidget extends StatelessWidget {
  
  String? selectedProduct;
  String? selectedWarehouse;
  String? selectedAdjustmentType;

  EditStockTransferWidget({super.key, this.selectedAdjustmentType, this.selectedProduct, this.selectedWarehouse});

final ctr = Get.find<ProductTransferController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Stock Transfer".tr,
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
            Text("From Warehouse".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: InputDecoration(
                hintText: "Select From Warehouse".tr,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(
                  value: "warehouse1",
                  child: Text("Warehouse 1"),
                ),
                DropdownMenuItem(
                  value: "warehouse2",
                  child: Text("Warehouse 2"),
                ),
                DropdownMenuItem(
                  value: "warehouse3",
                  child: Text("Warehouse 3"),
                ),
              ],
              onChanged: (value) {
                selectedProduct = value;
              },
            ),
                     
            const SizedBox(height: 15),
        
            Text("To Warehouse".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: InputDecoration(
                hintText: "Select To Warehouse".tr,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(
                  value: "warehouse1",
                  child: Text("Warehouse 1"),
                ),
                DropdownMenuItem(
                  value: "warehouse2",
                  child: Text("Warehouse 2"),
                ),
                DropdownMenuItem(
                  value: "warehouse3",
                  child: Text("Warehouse 3"),
                ),
              ],
              onChanged: (value) {
                selectedProduct = value;
              },
            ),

            const SizedBox(height: 15),
            Text("Product".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: InputDecoration(
                hintText: "Select Product".tr,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(
                  value: "apple",
                  child: Text("Apple"),
                ),
                DropdownMenuItem(
                  value: "banana",
                  child: Text("Banana"),
                ),
                DropdownMenuItem(
                  value: "orange",
                  child: Text("Orange"),
                ),
              ],
              onChanged: (value) {
                selectedProduct = value;
              },
            ),

            const SizedBox(height: 15),
            Text("Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Quantity".tr,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
 

            const SizedBox(height: 10),
            Text("Transfer Date".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
            const SizedBox(height: 5),

            Obx(() => InkWell(
                  onTap: () => ctr.pickDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ctr.formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )),
                     
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
                child: Text("Save".tr, style: const TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}