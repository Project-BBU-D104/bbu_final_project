import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class AddStockAdjustmentWidget extends StatelessWidget {
  
  String? selectedProduct;
  String? selectedWarehouse;
  String? selectedAdjustmentType;

  AddStockAdjustmentWidget({super.key, this.selectedAdjustmentType, this.selectedProduct, this.selectedWarehouse});

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
                  "Add Stock Adjustment".tr,
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
                  value: "orange",
                  child: Text("Orange"),
                ),
                DropdownMenuItem(
                  value: "snack",
                  child: Text("Snack"),
                ),
              ],
              onChanged: (value) {
                selectedProduct = value;
              },
            ),
            const SizedBox(height: 10),
            Text("Warehouse".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedWarehouse,
              decoration: InputDecoration(
                hintText: "Select Warehouse".tr,
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
                selectedWarehouse = value;
              },
            ),
        
            const SizedBox(height: 10),
             Text("Adjustment Type".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedAdjustmentType,
              decoration: InputDecoration(
                hintText: "Select Adjustment Type".tr,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: [
                DropdownMenuItem(
                  value: "increase",
                  child: Text("Increase".tr),
                ),
                DropdownMenuItem(
                  value: "decrease",
                  child: Text("Decrease".tr),
                ),
              ],
              onChanged: (value) {
                selectedAdjustmentType = value;
              },
            ),
        
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Reference NO".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    SizedBox(height: 5,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Reference Number".tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                )),
                 const SizedBox(width: 10),

             Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                  SizedBox(height: 5,),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Quantity".tr,
                      border: OutlineInputBorder(),
                    ),
                  ),
               ],
             )),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Previous Stock".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                SizedBox(height: 5,),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Previous Stock".tr,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              )
            ),
                 const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("New Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    
                    SizedBox(height: 5,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter New Quantity".tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                )),
              ],
            ),
            SizedBox(height: 10,),
            Text("Reason".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
               SizedBox(height: 5,),
              TextField(
                maxLines: 8,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter Reason".tr,
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
                  Navigator.pop(context);
                },
                child: Text("Save".tr,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}