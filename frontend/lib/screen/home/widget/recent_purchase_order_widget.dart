import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class RecentStockInWidget extends StatelessWidget {
  RecentStockInWidget({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {

    return Obx(() {

    final items = controller.recentPurchaseList ;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Row(
          children: [
            Text(
              "Recent Purchase Order".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.purchase);
              },
              child: Text(
                "View All".tr,
                style: TextStyle( fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.all(0),
            color: titleColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'NO'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Text(
                          textAlign: TextAlign.left,
                          'Supplier'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Price'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                     
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Date'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // Data rows
                  for (int i = 0; i < items.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            items[i]['invoice_no']?.toString() ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            textAlign: TextAlign.left,
                            items[i]['supplier_name']?.toString() ?? '',
                          ),
                        ),
                        
                        Expanded(
                          flex: 2,
                          child: Text(
                            items[i]['qty']?.toString() ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            items[i]['subtotal']?.toString() ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            DateFormatter.formatDate(
                              DateTime.tryParse(items[i]['purchase_date']?.toString() ?? ''),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    if (i != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
    });
  }
}