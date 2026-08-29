import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            SizedBox(height: 4),

            // KPI ROW
            // if(ctr.purchaseList.isNotEmpty)
            Row(
              children: [
                Obx(() =>
                  Expanded(
                    child: PurchaseKpiWidget(
                      title: "Total Purchases".tr,
                      value: ctr.purchaseList.length,
                    ),
                  ),
                ),
                
              ],
            ),

            const SizedBox(height: 10),

            // SEARCH
            SearchWidget(title: "Search Purchases..."),

            const SizedBox(height: 15),

            // LIST (ONLY SCROLL AREA)
            Obx(() { 
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (ctr.purchaseList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        "No purchase found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
              return Expanded(
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
              );
              }
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