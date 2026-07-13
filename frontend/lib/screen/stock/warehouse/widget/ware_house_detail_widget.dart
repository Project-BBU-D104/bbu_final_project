import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class WareHouseDetailWidget extends StatelessWidget {
  const WareHouseDetailWidget({super.key});


  @override
  Widget build(BuildContext context) {
    final warehouse = Get.arguments as Map<String, dynamic>;

    print(warehouse);
    return Scaffold(
      appBar: CustomAppBar(title: "WareHouse Detail"),
      body: Text("WareHouse Detail Widget"),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // ctr.deleteSupplier(supplierId: supplier.id!, context: context);
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
                    // ctr.editSupplier(supplier.id!,context);
                  },
                  icon: const Icon(Icons.edit),
                  label: Text("Edit".tr),
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