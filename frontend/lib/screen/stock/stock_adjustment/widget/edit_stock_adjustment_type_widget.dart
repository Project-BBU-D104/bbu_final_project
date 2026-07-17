import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class EditStockAdjustmentTypeWidget extends StatelessWidget {
  EditStockAdjustmentTypeWidget({super.key});

  final ctr = Get.find<StockAdjustmentController>();
  final warehouseCtr = Get.find<WarehouseController>();

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

            const Text(
              "Warehouse",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Obx(() {

              if(warehouseCtr.isLoading.value){

                return const Center(
                  child: CircularProgressIndicator(),
                );

              }
              return DropdownButtonFormField<String>(
                value: warehouseCtr.warehouseList.any(
                  (role) =>
                      role["id"].toString() == ctr.selectedWarehouse.value,
                )
                    ? ctr.selectedWarehouse.value
                    : null,
                decoration: InputDecoration(
                  hintText: "Select Warehouse".tr,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: warehouseCtr.warehouseList.map((warehouse) {
                  return DropdownMenuItem<String>(
                    value: warehouse["id"].toString(),
                    child: Text(
                      warehouse["name"] ?? "",
                    ),
                  );
                }).toList(),

                onChanged: (value){
                  ctr.selectedWarehouse.value = value;
                },
              );
            }),
        
            const SizedBox(height: 10),
            
            Text("Product".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            Obx(() {

              if(warehouseCtr.isLoading.value){

                return const Center(
                  child: CircularProgressIndicator(),
                );

              }
              return DropdownButtonFormField<String>(
                value: warehouseCtr.warehouseList.any(
                  (role) =>
                      role["id"].toString() == ctr.selectedWarehouse.value,
                )
                    ? ctr.selectedWarehouse.value
                    : null,
                decoration: InputDecoration(
                  hintText: "Select Warehouse".tr,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: warehouseCtr.warehouseList.map((warehouse) {
                  return DropdownMenuItem<String>(
                    value: warehouse["id"].toString(),
                    child: Text(
                      warehouse["name"] ?? "",
                    ),
                  );
                }).toList(),

                onChanged: (value){
                  ctr.selectedWarehouse.value = value;
                },
              );
            }),
            const SizedBox(height: 10),
            
             Text("Adjustment Type".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: ctr.selectedAdjustmentType.value,
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
                ctr.selectedAdjustmentType.value = value;
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
                  Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Previous Stock".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    SizedBox(height: 5,),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Previous Stock".tr,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  )
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Adjusted Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                      SizedBox(height: 5,),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Quantity".tr,
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("New Quantity".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                    
                    SizedBox(height: 5,),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "New Quantity".tr,
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
                child: Text("Update".tr,
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