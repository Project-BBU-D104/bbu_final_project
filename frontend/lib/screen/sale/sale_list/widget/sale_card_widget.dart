import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale_controller.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SaleCardWidget extends StatelessWidget {
  final Map<String, dynamic> sale;
  const SaleCardWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<SaleController>().gotoSaleListDetail(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: invoice info + amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Invoice number + company name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale['invoice_no'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${sale['total_amount']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00C896),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Amount + date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusWidget(text: sale['payment_status']),
                  ],
                ),
              ],
            ),
      
            const SizedBox(height: 16),
      
            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
      
            const SizedBox(height: 16),
      
            // Bottom row: badges + payment method
            Row(
              children: [
              
                const Spacer(),
      
                // Payment method
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Oct 24, 2023',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}