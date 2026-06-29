import 'package:flutter/material.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/widget/chip_widget.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Screen"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                  children: const [
                    CardItemWidget(),
                    CardItemWidget(),
                    CardItemWidget(),
                    CardItemWidget(),
                    CardItemWidget(),
                    CardItemWidget(),
                  ],
                ),
              ],
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const PaymentFooterWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}