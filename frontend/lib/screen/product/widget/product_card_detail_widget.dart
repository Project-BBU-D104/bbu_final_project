import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class ProductCardDetailWidget extends StatelessWidget {
  ProductCardDetailWidget({super.key});

  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments;

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
                  onPressed: () {
                    ctr.onDeleteProduct(product);
                  },
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
                  onPressed: () {
                    ctr.onEditProduct(product);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit Product"),
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

            /// IMAGE
            Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  product.asset,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// PRODUCT HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusWidget(text: product.status),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Color(0xff1DB584),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFORMATION
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
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [

                      _infoCard(
                        Icons.qr_code,
                        "SKU",
                        product.sku,
                      ),

                      _infoCard(
                        Icons.inventory_2_outlined,
                        "Stock",
                        "${product.stock} Units",
                      ),

                      _infoCard(
                        Icons.category_outlined,
                        "Category",
                        product.category,
                      ),

                      _infoCard(
                        Icons.straighten,
                        "Unit",
                        "Bottle",
                      ),

                      _infoCard(
                        Icons.local_shipping_outlined,
                        "Supplier",
                        "ABC Supplier",
                      ),

                      _infoCard(
                        Icons.schedule,
                        "Recency",
                        product.recency,
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
                children: const [

                  Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Fresh product with premium quality. Suitable for retail stores, supermarkets and wholesale businesses.",
                    style: TextStyle(
                      height: 1.6,
                      color: Colors.grey,
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
          color: Colors.black.withOpacity(.04),
          blurRadius: 15,
          offset: const Offset(0, 5),
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