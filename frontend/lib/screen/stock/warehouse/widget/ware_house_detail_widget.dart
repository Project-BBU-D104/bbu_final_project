import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class WareHouseDetailWidget extends StatelessWidget {
  WareHouseDetailWidget({super.key});

  final ctr = Get.put(WarehouseController());

  @override
  Widget build(BuildContext context) {
    final warehouse = Get.arguments as Map<String, dynamic>;

    final List stocks = warehouse["warehouse_stock"] ?? [];

    final int totalProducts = stocks.length;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FA),
      appBar: const CustomAppBar(title: "Warehouse Detail"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Warehouse Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: .05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundColor: successColor.withValues(alpha: .15),
                    child: Icon(
                      Icons.warehouse,
                      size: 40,
                      color: successColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    warehouse["name"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    warehouse["reference_no"],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  const Divider(height: 30),

                  _infoTile(
                    Icons.location_on,
                    "Location",
                    warehouse["location"],
                  ),

                  _infoTile(
                    Icons.note,
                    "Note",
                    warehouse["note"] ?? "-",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// Statistics
            if(totalProducts > 0)
            Row(
              children: [

                Expanded(
                  child: _statCard(
                    Icons.inventory_2,
                    "Products",
                    "$totalProducts",
                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),

            const SizedBox(height: 20),

            if(stocks.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Products",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              itemCount: stocks.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final stock = stocks[index];
                final product = stock["product"];

                return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              product["photo"] ?? "",
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.inventory_2,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product["category"]["name"],
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          product["barcode"].toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.straighten,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(product["unit"]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Divider(color: Colors.grey.shade300),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _infoBox(
                "Quantity",
                "${stock["qty"]}",
                Colors.blue,
                Icons.inventory,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _infoBox(
                "Cost",
                "\$${product["cost_price"]}",
                Colors.orange,
                Icons.attach_money,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _infoBox(
                "Sale",
                "\$${product["sale_price"]}",
                Colors.green,
                Icons.sell,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
              },
            )
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
                    ctr.deleteWarehouse(
                      context,
                      warehouse["id"]
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(52),
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
                    ctr.editWarehouse(context, warehouse["id"]);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
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

  static Widget _infoBox(
  String title,
  String value,
  Color color,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

  static Widget _infoTile(
      IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [

          Icon(icon, color: Colors.grey),

          const SizedBox(width: 10),

          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  static Widget _statCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 4),

          Text(title),
        ],
      ),
    );
  }
}