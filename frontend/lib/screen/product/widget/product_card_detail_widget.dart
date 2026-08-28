import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class ProductCardDetailWidget extends StatelessWidget {
  ProductCardDetailWidget({super.key});

  final ctr = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments as Map<String, dynamic>;

    final String photo = product['photo']?.toString() ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: const CustomAppBar(title: "Product Detail"),

      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ctr.onDeleteProduct(product['id'], context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Delete"),
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
                  onPressed: () => ctr.onEditProduct(product['id'], context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit"),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// PRODUCT IMAGE
            Container(
              width: double.infinity,
              height: 230,
              decoration: _cardDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: photo.isEmpty
                    ? Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Image.network(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 20),

            /// PRODUCT INFORMATION
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Product Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 18),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [

                      _infoCard(
                        Icons.inventory_2_outlined,
                        "Product Name",
                        product['name']?.toString() ?? "-",
                      ),
                      _infoCard(
                        Icons.qr_code,
                        "Barcode",
                        product['barcode']?.toString() ?? "-",
                      ),

                      _infoCard(
                        Icons.attach_money,
                        "Cost Price",
                        "\$${product['cost_price'] ?? 0}",
                      ),

                      _infoCard(
                        Icons.sell,
                        "Sale Price",
                        "\$${product['sale_price'] ?? 0}",
                      ),

                      _infoCard(
                        Icons.straighten,
                        "Unit",
                        product['unit'] ?? "-",
                      ),

                      _infoCard(
                        Icons.category_outlined,
                        "Category",
                        product['category']?['name'] ?? "-",
                      ),

                      _infoCard(
                        Icons.local_shipping_outlined,
                        "Supplier",
                        product['supplier']?['name'] ?? "-",
                      ),
                     
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    (product['description']?.toString().isNotEmpty ?? false)
                        ? product['description']
                        : "No description available.",
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: const Color(0xff1DB584),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

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
}