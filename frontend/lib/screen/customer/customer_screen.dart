import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/screen/customer/widget/customer_card_widget.dart';
import 'package:frontend/screen/customer/widget/customer_kpi_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});

  final ctr = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customer"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              SizedBox(height: 8,),

              SearchWidget(title: "Search Customers by name or ID".tr),

              SizedBox(height: 8,),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2,
                children: [
                    CustomerKpiWidget(
                    title: "Total Customers",
                    value: "1,000",
                    ),
                    CustomerKpiWidget(
                    title : "Active Customers",
                    value: "1,000",
                    ),
                    CustomerKpiWidget(
                    title: "Inactive Customers",
                    value: "1,000",
                    ),
                ],
              ),
              SizedBox(height: 8,),

              Obx(()
                => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctr.customerList.length,
                  itemBuilder: (context, index){
                    final customer = ctr.customerList[index];
                    return CustomerCardWidget(customer: customer);
                  },
                ),
              ),
              SizedBox(height: 70,),
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addCustomer(context);
        }, 
        child: const Icon(Icons.add)
      ),
    );
  }
}

 