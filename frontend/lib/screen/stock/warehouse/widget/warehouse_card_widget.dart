import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class WarehouseCardWidget extends StatelessWidget {
  final Map<String, dynamic> warehouse;
  const WarehouseCardWidget({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> Get.put(WarehouseController()).gotoWarehouseDetail(warehouse),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white, // ✅ changed to white
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  warehouse['reference_no'],
                  style: TextStyle(
                    color: Colors.black87, // changed
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 10),
      
            /// TITLE
            Text(
              warehouse['name'],
              style: TextStyle(
                color: Colors.black, // changed
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
      
            const SizedBox(height: 6),
      
            /// LOCATION
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  warehouse['location'],
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 14),
      
            /// NOTE BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                warehouse['note'],
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
      
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}