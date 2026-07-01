import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/sale_controller.dart';
import 'package:frontend/screen/payment/widget/input_amount_widget.dart';
import 'package:frontend/screen/payment/widget/payment_card_detail_widget.dart';
import 'package:frontend/screen/payment/widget/payment_method_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SaleWithPaymentScreen extends StatelessWidget {
   SaleWithPaymentScreen({super.key});


final ctr = Get.find<SaleController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              SizedBox(
                width: double.infinity,
                child: PaymentCardDetailWidget()
              ),
              SizedBox(height: 10,),
              SizedBox(
                width: double.infinity,
                child: InputAmountWidget()
              ),
               SizedBox(height: 10,),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                  
                    PaymentMethodCardWidget(),
                    SizedBox(height: 10,),
                    PaymentMethodCardWidget(),
                    SizedBox(height: 10,),
                    PaymentMethodCardWidget(),
                    SizedBox(height: 10,),
                    PaymentMethodCardWidget(),
                  ],
                )
              ),

            ],
          ),
        )
      ),

      bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save as draft
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: titleColor,
                    backgroundColor: dangerColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ctr.onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Confirm Payment"),
                ),
              ),
            ],
          ),
        ),
    );
  }
}