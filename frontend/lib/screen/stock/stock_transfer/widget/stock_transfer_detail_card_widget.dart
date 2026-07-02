import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_transfer_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockDetailCardWidget extends StatelessWidget {
  StockDetailCardWidget({super.key});

  final ctr = Get.find<StockTransferController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Stock Transfer Detail",
      ),
      body: Text("Stock Detail Card Widget"),

      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.onDeleteStockTransfer(1);
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
                    ctr.editStockTransfer(context, {});
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