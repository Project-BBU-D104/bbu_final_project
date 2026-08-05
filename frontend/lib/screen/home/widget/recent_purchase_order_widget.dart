import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class RecentStockInWidget extends StatelessWidget {
  const RecentStockInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      {'product': 'Coffee', 'qty': '2', 'price': '\$4.00', 'date': '7/1/2026'},
      {'product': 'Tea', 'qty': '1', 'price': '\$2.50', 'date': '7/1/2026'},
      {'product': 'Tea', 'qty': '1', 'price': '\$2.50', 'date': '7/1/2026'},
      {'product': 'Tea', 'qty': '1', 'price': '\$2.50', 'date': '7/1/2026'},
      {'product': 'Tea', 'qty': '1', 'price': '\$2.50', 'date': '7/1/2026'},
    ];

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
                        flex: 3,
                        child: Text(
                          'Product'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          child: Text(items[i]['product']!),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(items[i]['qty']!),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(items[i]['price']!),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            items[i]['date']!,
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
  }
}