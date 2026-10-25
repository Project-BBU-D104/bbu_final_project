import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
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
              // 🔹 Search bar (stays visible while the grid scrolls)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: SearchWidget(
                  title: "Search Product",
                  showScan: true,
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Product grid / empty state
              Expanded(
                child: Obx(() {
                  if (ctr.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final categories = ctr.filteredCategories;

                  if (categories.isEmpty) {
                    return Center(
                      child: _EmptyProductsState(
                        isSearching:
                            ctr.searchCtr.keyword.value.trim().isNotEmpty,
                        onClear: ctr.searchCtr.clear,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.map((category) {
                        final products = (category['products'] as List? ?? [])
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
                                        currency: ctr.currency.value,
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
                    ),
                  );
                }),
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
                            currency: ctr.currency.value,
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

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({
    required this.isSearching,
    required this.onClear,
  });

  final bool isSearching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 46,
              color: Color(0xFF1DB584),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isSearching ? 'No products found' : 'No products available',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? 'Try a different product name or barcode.'
                : 'Products will appear here once they are added.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear search'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1DB584),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
