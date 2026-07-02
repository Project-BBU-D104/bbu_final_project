import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockAdjustmentDetailWidget extends StatelessWidget {
  StockAdjustmentDetailWidget({super.key});

  final ctr = Get.find<StockAdjustmentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Stock Adjustment Detail".tr,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Stock Adjustment Detail Content"),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.onDeleteStockAdjustment(1);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text("Delete".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ctr.editStockAdjustment(context, {});
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text("Edit".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1DB584),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}