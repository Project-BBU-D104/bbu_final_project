import 'package:flutter/material.dart';

class WarehouseStockCardWidget extends StatelessWidget {
  final Map<String, dynamic> warehouseStock;

  const WarehouseStockCardWidget({
    super.key,
    required this.warehouseStock,
  });

  @override
  Widget build(BuildContext context) {
    final product = warehouseStock["product"];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [

          /// Product Header
          Row(
            children: [

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 38,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 15),

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
                      "Barcode: ${product["barcode"] ?? "-"}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                  ],
                ),
              ),

              _stockBadge(
                "${warehouseStock["qty"]}",
                product["unit"],
              ),

            ],
          ),


          const SizedBox(height: 18),


          /// Product Detail
          Row(
            children: [

              Expanded(
                child: _detailItem(
                  Icons.category,
                  "Category",
                  product["category"]["name"],
                ),
              ),

              Expanded(
                child: _detailItem(
                  Icons.local_shipping,
                  "Supplier",
                  product["supplier"]["name"],
                ),
              ),

            ],
          ),


          const SizedBox(height: 18),


          /// Price Section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                Expanded(
                  child: _priceItem(
                    "Cost Price",
                    "\$${product["cost_price"]}",
                    Colors.orange,
                  ),
                ),


                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),


                Expanded(
                  child: _priceItem(
                    "Sale Price",
                    "\$${product["sale_price"] ?? 0}",
                    Colors.green,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }


  Widget _stockBadge(String qty, String unit) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [

          Text(
            qty,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          Text(
            unit,
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 11,
            ),
          ),

        ],
      ),
    );
  }



  Widget _detailItem(
    IconData icon,
    String title,
    String value,
  ) {

    return Row(
      children: [

        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

            ],
          ),
        )

      ],
    );
  }



  Widget _priceItem(
    String title,
    String value,
    Color color,
  ) {

    return Column(
      children: [

        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

      ],
    );
  }
}