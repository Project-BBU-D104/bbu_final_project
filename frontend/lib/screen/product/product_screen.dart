import 'package:flutter/material.dart';
import 'package:frontend/screen/product/widget/filter_widget.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/product_controller.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

final productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Product',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchWidget(
                    title: 'Search Product',
                  ),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: [
                          FilterWidget(
                            icon: Icons.tune,
                            label: productCtrl.selectedCategory.value == 'All'
                                ? 'Category'
                                : productCtrl.selectedCategory.value,
                            isSelected:
                                productCtrl.selectedCategory.value != 'All',
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
                          const SizedBox(width: 8),
                          FilterWidget(
                            icon: Icons.list,
                            label: productCtrl.selectedRecency.value == 'All'
                                ? 'Recency'
                                : productCtrl.selectedRecency.value,
                            isSelected:
                                productCtrl.selectedRecency.value != 'All',
                            onPressed: () => _openFilterBottomSheet(
                              context,
                              'recency',
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

            Expanded(
              child: Obx(() {
                final list = productCtrl.filteredItems;
                if (list.isEmpty) {
                  return Center(
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
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, idx) =>
                      ProductCardWidget(product: list[idx]),
                );
              }),
            ),
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
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
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
    if (type == 'recency') {
      options = ['All', 'Newest', 'Oldest'];
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by ${type.capitalizeFirst}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (opt) => ListTile(
                title: Text(opt),
                trailing:
                    (type == 'category' &&
                            ctrl.selectedCategory.value == opt) ||
                        (type == 'status' &&
                            ctrl.selectedStatus.value == opt) ||
                        (type == 'recency' && ctrl.selectedRecency.value == opt)
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