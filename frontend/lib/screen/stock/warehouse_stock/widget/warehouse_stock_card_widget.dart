import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class WarehouseStockCardWidget extends StatelessWidget {
  final Map<String, dynamic> warehouseStock;

  WarehouseStockCardWidget({
    super.key,
    required this.warehouseStock,
  });

  final ctr = Get.find<WarehouseStockController>();

  @override
  Widget build(BuildContext context) {
    final product = warehouseStock["product"];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.blue,
                  size: 32,
                ),
              ),

              const SizedBox(width: 14),

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

                    Text(
                      "${warehouseStock["warehouse"]['name'] ?? "-"}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: (){
                      ctr.editWarehouseStock(
                        context,
                        warehouseStock["id"],
                      );
                    },
                    value: "edit",
                    child: Text("Edit"),
                  ),

                  PopupMenuItem(
                    onTap: (){
                      ctr.onDeleteWarehouseStock(warehouseStock["id"], context);
                    },
                    value: "delete",
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 18),

          /// STOCK CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                Text(
                  "Available Stock",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${warehouseStock["qty"]}",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),

                // Text(
                //   product["unit"] ?? "",
                //   style: TextStyle(
                //     color: Colors.green.shade700,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// CATEGORY + SUPPLIER
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: Icons.category_rounded,
                  title: "Category",
                  value: product["category"]["name"] ?? "-",
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),

          const SizedBox(height: 20),

          /// PRICE
          Row(
            children: [

              Expanded(
                child: _priceCard(
                  "Cost Price",
                  "\$${product["cost_price"]}",
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _priceCard(
                  "Sale Price",
                  "\$${product["sale_price"]}",
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceCard(String title, String price, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            price,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _infoCard({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withValues(alpha: 0.2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}