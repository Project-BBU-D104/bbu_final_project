import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/sale_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SaleListDetailWidget extends StatelessWidget {
  SaleListDetailWidget({super.key});

  final ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sale List Detail"),
      body: Text("Sale List Detail Widget"),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.onDeleteSale();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text("Delete".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ctr.onNewSale();
                  },
                  icon: const Icon(Icons.add),
                  label: Text("New Sale".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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