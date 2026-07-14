import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class AddWarehouseStockWidget extends StatelessWidget {
  
  String? selectedProduct;
  String? selectedWarehouse;
  String? selectedAdjustmentType;

  AddWarehouseStockWidget({super.key, this.selectedAdjustmentType, this.selectedProduct, this.selectedWarehouse});

final ctr = Get.find<WarehouseStockController>();

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
                  "Add Warehouse",
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
      ),
    );
  }
}