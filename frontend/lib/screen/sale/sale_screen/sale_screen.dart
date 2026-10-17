import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SaleScreen extends StatelessWidget {
  SaleScreen({super.key});

  final ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Sale",
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2; // phone
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 3; // small tablet
          } else {
            crossAxisCount = 4; // large screen
          }

          return Column(
            children: [
              // 🔹 Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        if (ctr.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (ctr.categories.isEmpty) {
                          return const Center(child: Text('No products found'));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ctr.categories.map((category) {
                            final products =
                                (category['products'] as List? ?? [])
                                    .cast<Map<String, dynamic>>();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      category['name']?.toString() ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (products.isEmpty)
                                    const Text('No products in this category')
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: products.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 0.78,
                                          ),
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        final productId = product['id'] as int;
                                        return Obx(
                                          () => CardItemWidget(
                                            product: product,
                                            quantity:
                                                ctr.cart[productId]?['qty']
                                                    as int? ??
                                                0,
                                            onTap: () =>
                                                ctr.addProduct(product),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // 🔹 Bottom Footer (fixed, safe)
              Obx(
                () => ctr.totalItems > 0
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: PaymentFooterWidget(
                            itemCount: ctr.totalItems,
                            total: ctr.subtotal,
                            onTap: ctr.onCurrentSale,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}
