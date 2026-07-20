import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockDetailCardWidget extends StatelessWidget {
  StockDetailCardWidget({super.key});

  final ctr = Get.find<ProductTransferController>();

  final Map<String, dynamic> productTransfer = Get.arguments;

  Widget _item(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.green),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = productTransfer["product"];
    final fromWarehouse = productTransfer["from_warehouse"];
    final toWarehouse = productTransfer["to_warehouse"];

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Stock Transfer Detail",
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Product Card
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(product["photo"]),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product["category"]["name"],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Transfer Information
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Transfer Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Divider(height: 25),

                    _item(
                      "Reference No",
                      productTransfer["reference_no"] ?? "-",
                      icon: Icons.receipt_long,
                    ),

                    _item(
                      "From Warehouse",
                      fromWarehouse["name"],
                      icon: Icons.warehouse,
                    ),

                    _item(
                      "To Warehouse",
                      toWarehouse["name"],
                      icon: Icons.store,
                    ),

                    _item(
                      "Quantity",
                      "${productTransfer["qty"]} ${product["unit"]}",
                      icon: Icons.inventory_2,
                    ),

                    _item(
                      "Barcode",
                      product["barcode"].toString(),
                      icon: Icons.qr_code,
                    ),

                    _item(
                      "Supplier",
                      product["supplier"]["name"],
                      icon: Icons.person,
                    ),

                    _item(
                      "Transfer Date",
                      DateFormatter.formatDate(DateTime.tryParse(productTransfer['transfer_date'] ?? ''),),
                      icon: Icons.calendar_today,
                    ),

                    _item(
                      "Created At",
                      DateFormatter.formatDate(DateTime.tryParse(productTransfer['created_at'] ?? ''),),
                      icon: Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                    ctr.onDeleteStockTransfer(
                        context, productTransfer["id"]);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(55),
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
                    ctr.editStockTransfer(
                      context,
                      productTransfer,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1DB584),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
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