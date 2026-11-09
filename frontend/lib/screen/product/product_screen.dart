import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    // The desktop shell shrinks the child constraints, so this is the width
    // actually available to the content.
    final availableWidth = MediaQuery.sizeOf(context).width;
    final outer = availableWidth < 600 ? 16.0 : 32.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product',
        showRefresh: true,
        onRefresh: productCtrl.getProducts,
      ),

      body: RefreshIndicator(
        onRefresh: productCtrl.getProducts,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                /// SEARCH + FILTER SECTION
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: outer),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        SearchWidget(title: 'Search Product', showScan: true),

                        const SizedBox(height: 16),

                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterWidget(
                                icon: Icons.tune,
                                label: productCtrl.filterCategory.value == 'All'
                                    ? 'Category'.tr
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

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                /// ERROR BANNER: a refresh failed but products remain visible.
                Obx(() {
                  if (productCtrl.loadError.value.isEmpty ||
                      productCtrl.isLoading.value ||
                      productCtrl.filteredItems.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(outer, 0, outer, 12),
                    sliver: SliverToBoxAdapter(
                      child: Material(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_off,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Could not load products'.tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => productCtrl.getProducts(),
                                child: Text('Retry'.tr),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                /// PRODUCT LIST
                Obx(() {
                  if (productCtrl.isLoading.value &&
                      productCtrl.products.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final list = productCtrl.filteredItems;

                  if (list.isEmpty) {
                    // Error takes precedence over any empty-result message.
                    final hasError = productCtrl.loadError.value.isNotEmpty;
                    final isSearching = productCtrl.searchQuery.value.isNotEmpty;
                    final hasFilters = productCtrl.hasActiveFilters;

                    final IconData icon;
                    final String message;
                    if (hasError) {
                      icon = Icons.cloud_off;
                      message = 'Could not load products'.tr;
                    } else if (isSearching) {
                      icon = Icons.search_off;
                      message = 'No products found'.tr;
                    } else if (hasFilters) {
                      icon = Icons.filter_alt_off;
                      message = 'No products match the selected filter'.tr;
                    } else {
                      icon = Icons.inventory_2_outlined;
                      message = 'No products available'.tr;
                    }

                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),

                              if (hasError) ...[
                                const SizedBox(height: 8),

                                Text(
                                  productCtrl.loadError.value,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  if (hasError)
                                    OutlinedButton.icon(
                                      onPressed: () => productCtrl.getProducts(),
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: Text('Retry'.tr),
                                    ),
                                  if (!isSearching && hasFilters)
                                    OutlinedButton.icon(
                                      onPressed: productCtrl.clearFilters,
                                      icon: const Icon(
                                        Icons.filter_alt_off,
                                        size: 18,
                                      ),
                                      label: Text('Clear filters'.tr),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(outer, 0, outer, 12),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.crossAxisExtent >= 760) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              if (index == 0) {
                                return const _ProductTableHeader();
                              }
                              return ProductTableWidget(product: list[index - 1]);
                            }, childCount: list.length + 1),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                ProductCardWidget(product: list[index]),
                            childCount: list.length,
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productCtrl.gotoAddProduct();
        },
        tooltip: 'Add Product'.tr,
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 28),
      ),
    );
  }

  void _openFilterBottomSheet(
    BuildContext ctx,
    String type,
    ProductController ctrl,
  ) {
    final theme = Theme.of(ctx);
    List<String> options = [];

    if (type == 'category') {
      options = ctrl.filterCategoryOptions;
    }
    if (type == 'status') {
      options = ['All', 'IN STOCK', 'LOW STOCK', 'OUT OF STOCK'];
    }

    Get.bottomSheet(
      // Material host so ListTile ink stays visible on the themed surface.
      Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by ${type.capitalizeFirst}'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
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
                          // Business values (category names) stay untranslated;
                          // only the 'All' sentinel is UI copy.
                          title: Text(
                            opt == 'All' ? 'All'.tr : opt,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          trailing:
                              (type == 'category' &&
                                      ctrl.filterCategory.value == opt) ||
                                  (type == 'status' &&
                                      ctrl.selectedStatus.value == opt) ||
                                  (type == 'recency' &&
                                      ctrl.selectedRecency.value == opt)
                              ? Icon(Icons.check, color: theme.colorScheme.primary)
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
      ),
      isScrollControlled: true,
    );
  }
}

class _ProductTableHeader extends StatelessWidget {
  const _ProductTableHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                const SizedBox(width: 52),
                Text('Product'.tr, style: style),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text('Barcode'.tr, style: style)),
          Expanded(flex: 2, child: Text('Price'.tr, style: style)),
          Expanded(flex: 2, child: Text('Created'.tr, style: style)),
        ],
      ),
    );
  }
}
