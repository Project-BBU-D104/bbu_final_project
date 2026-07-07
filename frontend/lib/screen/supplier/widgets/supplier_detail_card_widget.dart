import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/models/supplier_model.dart';

class SupplierDetailCardWidget extends StatelessWidget {
  SupplierDetailCardWidget({super.key});

  final ctr = Get.find<SupplierController>();

  @override
  Widget build(BuildContext context) {
    final supplier = Get.arguments as SupplierModel?;

    if (supplier == null) {
      return  Scaffold(
        body: Center(child: Text("No supplier data found".tr)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      appBar: CustomAppBar(
        title: "Supplier Detail".tr,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _card(),
              child: Column(
                children: [

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xff1DB584),
                        child: Text(
                          (supplier.name)[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              supplier.email ?? '-',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      StatusWidget(
                        text: supplier.status == true
                            ? "Active"
                            : "Inactive",
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// QUICK INFO GRID
                  Row(
                    children: [
                      _miniBox(Icons.phone, supplier.phone),
                      const SizedBox(width: 10),
                      _miniBox(Icons.location_on, "Map"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: _card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Supplier Information".tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _row("Address", supplier.address ?? '-'),
                  _row("Created", supplier.createdAt != null
                    ? supplier.createdAt!.toString().substring(0, 10)
                    : "",),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.deleteSupplier(supplierId: supplier.id!, context: context);
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
                    ctr.editSupplier(context);
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

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 6),
        )
      ],
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr,
            style: const TextStyle(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBox(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xff1DB584)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text.tr,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}