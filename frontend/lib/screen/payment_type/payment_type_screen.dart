import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/screen/payment_type/widget/payment_type_card_widget.dart';
import 'package:frontend/screen/payment_type/widget/payment_type_table_widget.dart';
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Payment Type"),

              SizedBox(height: 10),

              Obx(() {
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (ctr.paymentTypeList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text("No Payment Type".tr)),
                  );
                }
                if (ctr.searchPaymentType.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text("Search Payment Type Not Found".tr),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final paymentTypes = ctr.searchPaymentType.toList();
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: paymentTypes.length,
                        itemBuilder: (context, index) => PaymentTypeCardWidget(
                          paymentType: paymentTypes[index],
                        ),
                      );
                    }

                    return PaymentTypeTableWidget(paymentTypes: paymentTypes);
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addPaymentType(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
