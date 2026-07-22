import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class AddWarehouseWidget extends StatelessWidget {
 
  AddWarehouseWidget({super.key});

final ctr = Get.find<WarehouseController>();

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
                    fontSize: 22,
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

            SizedBox(height: 10),

            Text("Warehouse Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5,),
            TextField(
              controller: ctr.warehouseNameController,
              decoration: InputDecoration(
                hintText: "Enter Warehouse Name".tr,
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            Text("Reference No".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.warehouseReferenceNoController,
              decoration: InputDecoration(
                hintText: "Enter Reference No".tr,
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            Text("Location".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.warehouseLocationController,
              decoration: InputDecoration(
                hintText: "Enter Location".tr,
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            Text("Note".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              controller: ctr.warehouseNoteController,
              maxLines: 5,
              minLines: 2,
              decoration: InputDecoration(
                hintText: "Enter Note".tr,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),
        
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                ),
                onPressed: () {
                  ctr.onSaveWarehouse();
                },
                child: Text("Save",
                 style: TextStyle(fontSize: 18, color: titleColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}