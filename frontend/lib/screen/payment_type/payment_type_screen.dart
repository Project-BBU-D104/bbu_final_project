import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/screen/payment_type/widget/payment_type_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PaymentTypeScreen extends StatelessWidget {
  PaymentTypeScreen({super.key});

  final ctr = Get.put(PaymentTypeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment Type"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
          
              SearchWidget(title: "Search Payment Type"),
              
              SizedBox(height: 10),

              Obx(()
                {

                  if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (ctr.paymentTypeList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text("No Payment Type".tr),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctr.paymentTypeList.length,
                    itemBuilder: (context, index){
                      final paymentType = ctr.paymentTypeList[index];
                      return PaymentTypeCardWidget(paymentType: paymentType);
                    },
                  );
                }
              )
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addPaymentType(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}