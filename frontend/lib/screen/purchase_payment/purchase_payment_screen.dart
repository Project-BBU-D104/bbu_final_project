import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentScreen extends StatelessWidget {
  PurchasePaymentScreen({super.key});

  final ctr = Get.find<PurchasePaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Payment"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SearchWidget(
                title: "Search Purchase Payment",
              ),

              SizedBox(height: 10,),

              Row(
                children: [
                  ChipWidget(title: "All"),
                  ChipWidget(title: "Pending"),
                  ChipWidget(title: "Completed"),
                  ChipWidget(title: "Canceled"),
                ]
              ),

              SizedBox(height: 10,),

              Obx((){

                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: ctr.purchasePaymentList.length,
                  itemBuilder: (context, index) {
                    return PurchasePaymentCardWidget(
                      payment: ctr.purchasePaymentList[index],
                    );
                  }
                );
              })
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add)
      ),
    );
  }
}