import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale_controller.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class CurrentSaleWidget extends StatelessWidget {
  CurrentSaleWidget({super.key});

  final ctr = Get.put(SaleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Current Sale"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5),
          
              SizedBox(
                width: double.infinity,
                child: SelectCustomerCardWidget()
              ),
          
              CurrentSaleItemWidget(
                imageUrl: "https://www.1001spirits.com/tuotekuvat/1200x1200/Coca%20Cola%20Classic%2024x0%2C33%20l.png",
                productName: "Product Name",
                unitPrice: 1000,
                quantity: 1,
                subtotal: 1000,
          
              ),
              CurrentSaleItemWidget(
                imageUrl: "https://www.1001spirits.com/tuotekuvat/1200x1200/Coca%20Cola%20Classic%2024x0%2C33%20l.png",
                productName: "Product Name",
                unitPrice: 1000,
                quantity: 1,
                subtotal: 1000,
          
              ),
              CurrentSaleItemWidget(
                imageUrl: "https://www.1001spirits.com/tuotekuvat/1200x1200/Coca%20Cola%20Classic%2024x0%2C33%20l.png",
                productName: "Product Name",
                unitPrice: 1000,
                quantity: 1,
                subtotal: 1000,
              ),
              CurrentSaleItemWidget(
                imageUrl: "https://www.1001spirits.com/tuotekuvat/1200x1200/Coca%20Cola%20Classic%2024x0%2C33%20l.png",
                productName: "Product Name",
                unitPrice: 1000,
                quantity: 1,
                subtotal: 1000,
              ),
              CurrentSaleItemWidget(
                imageUrl: "https://www.1001spirits.com/tuotekuvat/1200x1200/Coca%20Cola%20Classic%2024x0%2C33%20l.png",
                productName: "Product Name",
                unitPrice: 1000,
                quantity: 1,
                subtotal: 1000,
              ),
          
              SummaryOrderWidget(),
            ]
          ),
        ),
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
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Save as draft
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Draft"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ctr.onPayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Payment"),
                ),
              ),
            ],
          ),
        ),
    );
  }
}