import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/screen/product/widget/filter_widget.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/product_controller.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Product',
      ),

      body: CustomScrollView(
        slivers: [
          /// SEARCH + FILTER SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchWidget(title: 'Search Product'),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: [
                          FilterWidget(
                            icon: Icons.tune,
                            label: productCtrl.filterCategory.value == 'All'
                                ? 'Category'
                                : productCtrl.filterCategory.value,
                            isSelected:
                                productCtrl.filterCategory.value != 'All',
                            onPressed: () => _openFilterBottomSheet(
                              context,
                              'category',
                              productCtrl,
                            ),
                          ),
                          const SizedBox(width: 8),

                          FilterWidget(
                            icon: Icons.sort,
                            label: productCtrl.selectedStatus.value == 'All'
                                ? 'Status'
                                : productCtrl.selectedStatus.value,
                            isSelected:
                                productCtrl.selectedStatus.value != 'All',
                            onPressed: () => _openFilterBottomSheet(
                              context,
                              'status',
                              productCtrl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          /// PRODUCT LIST
          Obx(() {

            if (productCtrl.isLoading.value) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final list = productCtrl.filteredItems;

            if (list.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    return ProductCardWidget(product: list[idx]);
                  },
                  childCount: list.length,
                ),
              ),
            );
          }),
           const SliverToBoxAdapter(child: SizedBox(height: 70)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productCtrl.gotoAddProduct();
        },
        backgroundColor: const Color(0xFF1DB584),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.add, color: lightColor, size: 28),
      ),
    );
  }

  void _openFilterBottomSheet(
    BuildContext ctx,
    String type,
    ProductController ctrl,
  ) {
    List<String> options = [];

    if (type == 'category') {
      options = ['All', 'Sting', 'Cocacola', 'Ize', 'Energy Drinks'];
    }
    if (type == 'status') {
      options = ['All', 'IN STOCK', 'LOW STOCK', 'OUT OF STOCK'];
    }
    

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by ${type.capitalizeFirst}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (opt) => ListTile(
                title: Text(opt),
                trailing: (type == 'category' &&
                            ctrl.selectedCategory.value == opt) ||
                        (type == 'status' &&
                            ctrl.selectedStatus.value == opt) ||
                        (type == 'recency' &&
                            ctrl.selectedRecency.value == opt)
                    ? const Icon(Icons.check, color: Color(0xFF1DB584))
                    : null,
                onTap: () {
                  if (type == 'category') ctrl.selectedCategory.value = opt;
                  if (type == 'status') ctrl.selectedStatus.value = opt;
                  if (type == 'recency') ctrl.selectedRecency.value = opt;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}