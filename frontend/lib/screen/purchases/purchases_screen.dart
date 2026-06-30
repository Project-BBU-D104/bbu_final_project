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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              
              Row(
                children: [
                  Expanded(
                    child: PurchaseKpiWidget(
                      title: "Total Purchases",
                      value: 1000,
                      
                    ),
                  ),
                  Expanded(
                    child: PurchaseKpiWidget(
                      title: "Active Supplier",
                      value: 1000,
                      
                    ),
                  ),
                ],
              ),
              
              SearchWidget(title: "Search Purchases..."),

              PurchaseCardWidget(),

            ]
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addPurchase(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}