import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/screen/product/widget/filter_widget.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/screen/product/widget/product_table_widget.dart';
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
        showRefresh: true,
        onRefresh: productCtrl.getProducts,
      ),

      body: RefreshIndicator(
        onRefresh: productCtrl.getProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// SEARCH + FILTER SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    SearchWidget(title: 'Search Product', showScan: true),

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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 2)),

            /// PRODUCT LIST
            Obx(() {
              if (productCtrl.isLoading.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final list = productCtrl.filteredItems;

              if (list.isEmpty) {
                final hasError = productCtrl.loadError.value.isNotEmpty;
                final isSearching = productCtrl.searchQuery.value.isNotEmpty;
                final hasFilters = productCtrl.hasActiveFilters;

                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasError
                                ? Icons.cloud_off
                                : hasFilters && !isSearching
                                ? Icons.filter_alt_off
                                : Icons.inbox,
                            size: 64,
                            color: Colors.grey[300],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            isSearching
                                ? 'No products found'
                                : hasError
                                ? 'Could not load products'
                                : hasFilters
                                ? 'No products match the selected filter'
                                : 'No products available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),

                          if (hasError && !isSearching) ...[
                            const SizedBox(height: 8),

                            Text(
                              productCtrl.loadError.value,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],

                          if (!isSearching) ...[
                            const SizedBox(height: 16),

                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => productCtrl.getProducts(),
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Retry'),
                                ),
                                if (hasFilters)
                                  OutlinedButton.icon(
                                    onPressed: productCtrl.clearFilters,
                                    icon: const Icon(
                                      Icons.filter_alt_off,
                                      size: 18,
                                    ),
                                    label: const Text('Clear filters'),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverLayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.crossAxisExtent >= 760) {
                    return SliverPadding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                        left: 12,
                        right: 12,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == 0) {
                            return const _ProductTableHeader();
                          }
                          return ProductTableWidget(product: list[index - 1]);
                        }, childCount: list.length + 1),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCardWidget(product: list[index]),
                        childCount: list.length,
                      ),
                    ),
                  );
                },
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 70)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productCtrl.gotoAddProduct();
        },
        backgroundColor: const Color(0xFF1DB584),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      options = ctrl.filterCategoryOptions;
    }
    if (type == 'status') {
      options = ['All', 'IN STOCK', 'LOW STOCK', 'OUT OF STOCK'];
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
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
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: options
                      .map(
                        (opt) => ListTile(
                          title: Text(opt),
                          trailing:
                              (type == 'category' &&
                                      ctrl.filterCategory.value == opt) ||
                                  (type == 'status' &&
                                      ctrl.selectedStatus.value == opt) ||
                                  (type == 'recency' &&
                                      ctrl.selectedRecency.value == opt)
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF1DB584),
                                )
                              : null,
                          onTap: () {
                            if (type == 'category') {
                              ctrl.filterCategory.value = opt;
                            }
                            if (type == 'status') {
                              ctrl.selectedStatus.value = opt;
                            }
                            if (type == 'recency') {
                              ctrl.selectedRecency.value = opt;
                            }
                            Get.back();
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ProductTableHeader extends StatelessWidget {
  const _ProductTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                const SizedBox(width: 40),
                const SizedBox(width: 12),
                Text('PRODUCT', style: style),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text('BARCODE', style: style)),
          Expanded(flex: 2, child: Text('PRICE', style: style)),
          Expanded(flex: 2, child: Text('CREATED', style: style)),
        ],
      ),
    );
  }
}
