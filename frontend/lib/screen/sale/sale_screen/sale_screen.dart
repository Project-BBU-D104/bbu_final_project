import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SaleScreen extends StatelessWidget {
  SaleScreen({super.key});

  final ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Sale",
        onBack: () {
          Get.offAllNamed('/home');
        },
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2; // phone
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 3; // small tablet
          } else {
            crossAxisCount = 4; // large screen
          }

          return Column(
            children: [
              // 🔹 Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          ChipWidget(title: "All"),
                          ChipWidget(title: "Pending"),
                          ChipWidget(title: "Completed"),
                          ChipWidget(title: "Canceled"),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          return const CardItemWidget();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Bottom Footer (fixed, safe)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child:  PaymentFooterWidget(
                    onTap: () {
                        ctr.onCurrentSale();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}