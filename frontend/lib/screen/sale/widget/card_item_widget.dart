import 'package:flutter/material.dart';

class CardItemWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final VoidCallback onTap;

  const CardItemWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photo = product['photo']?.toString() ?? '';
    final price = double.tryParse(product['sale_price']?.toString() ?? '') ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: photo.isEmpty
                      ? const Center(
                          child: Icon(Icons.inventory_2_outlined, size: 44),
                        )
                      : Image.network(
                          photo,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 44,
                                ),
                              ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text('\$${price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
            if (quantity > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
