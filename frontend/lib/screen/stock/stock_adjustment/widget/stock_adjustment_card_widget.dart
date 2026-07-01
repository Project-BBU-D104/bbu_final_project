import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentCardWidget extends StatelessWidget {

  final Map<String, dynamic> stockAdjustment;
  const StockAdjustmentCardWidget({super.key, required this.stockAdjustment});
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<StockAdjustmentController>().gotoStockAdjustmentDetailScreen(stockAdjustment),
      child: Card(
        elevation: 0,
        color: titleColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
      
                      const SizedBox(width: 12),
      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Stock Adjustment",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
      
                          Text(
                            stockAdjustment["id"] ?? "N/A",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      
      
              const SizedBox(height: 20),
      
      
              // Product section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
      
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
      
                        Text(
                          "Product",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
      
                        SizedBox(height: 4),
      
                        Text(
                          stockAdjustment["product_name"] ?? "N/A",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
      
                      ],
                    ),
      
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${stockAdjustment['adjustment_type'] == 'increase' ? '+' : '-'}${stockAdjustment['qty'] ?? '0'}",
                        style: TextStyle(
                          color: successColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
      
                  ],
                ),
              ),
      
      
              const SizedBox(height: 16),
      
      
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
      
                  Row(
                    children: [
      
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
      
                      const SizedBox(width: 8),
      
                      Text(
                        "Oct 24, 2023 • 10:00 AM",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
      
                    ],
                  ),
      
      
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                  )
      
                ],
              )
      
            ],
          ),
        ),
      ),
    );
  }
}