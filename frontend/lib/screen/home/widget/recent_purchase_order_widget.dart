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
            margin: EdgeInsets.zero,
            color: titleColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: items.isEmpty
                    ? SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "No Data".tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    :  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                           textAlign: TextAlign.start,
                          'NO'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Text(
                          textAlign: TextAlign.start,
                          'Supplier'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        flex: 2,
                        child: Text(
                           textAlign: TextAlign.center,
                          'Qty'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                           textAlign: TextAlign.end,
                          'Total'.tr,
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
                          flex: 2,
                          child: Text(
                             textAlign: TextAlign.start,
                            items[i]['invoice_no']?.toString() ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            textAlign: TextAlign.start,
                            items[i]['supplier_name']?.toString() ?? '',
                          ),
                        ),
                        
                        Expanded(
                          flex: 2,
                          child: Text(
                             textAlign: TextAlign.center,
                            items[i]['qty']?.toString() ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                             textAlign: TextAlign.end,
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