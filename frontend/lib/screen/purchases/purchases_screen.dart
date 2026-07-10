import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_card_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_kpi_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchasesScreen extends StatelessWidget {
  PurchasesScreen({super.key});

  final ctr = Get.find<PurchaseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchases"),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            // KPI ROW
            Row(
              children: [
                Expanded(
                  child: PurchaseKpiWidget(
                    title: "Total Purchases".tr,
                    value: 1000,
                  ),
                ),
                Expanded(
                  child: PurchaseKpiWidget(
                    title: "Active Supplier".tr,
                    value: 1000,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SEARCH
            SearchWidget(title: "Search Purchases..."),

            const SizedBox(height: 10),

            // LIST (ONLY SCROLL AREA)
            Obx(() => Expanded(
                child: ListView.builder(
                  itemCount: ctr.purchaseList.length,
                  padding: const EdgeInsets.only(bottom: 70),
                  itemBuilder: (context, index) {
                    final purchase = ctr.purchaseList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PurchaseCardWidget(purchase: purchase),
                    );
                  },
                ),
              ),
            ),            
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addPurchase(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}