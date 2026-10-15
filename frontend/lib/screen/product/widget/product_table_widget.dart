import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class ProductTableWidget extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductTableWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(
      product['created_at']?.toString() ?? '',
    );

    return InkWell(
      onTap: () => Get.find<ProductController>().gotoProductDetail(product),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      product['photo']?.toString() ?? '',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product['name']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                product['barcode']?.toString() ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(
                  double.tryParse(product['sale_price']?.toString() ?? '') ?? 0,
                  product['currency'],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF168B68),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormatter.formatDate(createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
