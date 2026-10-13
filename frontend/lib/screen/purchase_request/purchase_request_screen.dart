import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchaseRequestScreen extends StatelessWidget {
  PurchaseRequestScreen({super.key});

  final ctr = Get.find<PurchaseRequestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Request"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Purchase Request"),

              const SizedBox(height: 10),

              CardPurchaseRequestWidget()


            ]
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => ctr.addPurchaseRequest(context),
        child: const Icon(Icons.add)
      ),
    );
  }
}