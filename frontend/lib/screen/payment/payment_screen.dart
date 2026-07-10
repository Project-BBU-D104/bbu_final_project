import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/screen/payment/widget/payment_card_list_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
 PaymentScreen({super.key});

  final ctr = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10,),
              SearchWidget(title: "Search Payment"),
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
        
              Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctr.paymentList.length,
                  itemBuilder: (context, index) => 
                     PaymentCardListWidget(payment: ctr.paymentList[index],),
                  ),
                ),
              SizedBox(height: 70,)
            ]
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // ctr.addRole(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}