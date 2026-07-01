import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/stock_transfer_controller.dart';
import 'package:get/get.dart';

class AddStockTransferWidget extends StatelessWidget {
  
  String? selectedProduct;
  String? selectedWarehouse;
  String? selectedAdjustmentType;

  AddStockTransferWidget({super.key, this.selectedAdjustmentType, this.selectedProduct, this.selectedWarehouse});

final ctr = Get.find<StockTransferController>();

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
                const Text(
                  "Add Stock Transfer",
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
            Text("From Warehouse", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: const InputDecoration(
                hintText: "From Warehouse",
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
        
            Text("To Warehouse", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: const InputDecoration(
                hintText: "To Warehouse",
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
            Text("Product", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              decoration: const InputDecoration(
                hintText: "Select Product",
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
            Text("Quantity", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Quantity",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
 

            const SizedBox(height: 10),
            const Text("Transfer Date", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                  foregroundColor: titleColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}