import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/product/widget/filter_widget.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/screen/product/widget/product_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'Products', useTheme: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.all(gutter),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth < 600
                                        ? constraints.maxWidth - gutter * 2
                                        : 580,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (desktop) ...[
                                        Row(
                                          children: [
                                            IconButton.outlined(
                                              tooltip: 'Back'.tr,
                                              onPressed: () => Get.back(),
                                              icon: const Icon(
                                                Icons.arrow_back,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Semantics(
                                                header: true,
                                                child: Text(
                                                  'Products'.tr,
                                                  style: theme
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: -0.5,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        'Manage products, barcodes, prices, and stock.'
                                            .tr,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    IconButton.outlined(
                                      tooltip: 'Refresh'.tr,
                                      onPressed: productCtrl.getProducts,
                                      style: IconButton.styleFrom(
                                        minimumSize: const Size(48, 48),
                                        side: BorderSide(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.12),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh, size: 20),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          productCtrl.addProduct(context),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 48),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add, size: 20),
                                      label: Text('Add Product'.tr),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            LayoutBuilder(
                              builder: (context, content) => Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 20,
                                runSpacing: 12,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: content.maxWidth < 440
                                            ? content.maxWidth
                                            : 420,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.08),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const SearchWidget(
                                            title: 'Search Product',
                                            showScan: true,
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => FilterWidget(
                                          icon: Icons.tune,
                                          label:
                                              productCtrl
                                                      .filterCategory
                                                      .value ==
                                                  'All'
                                              ? 'Category'.tr
                                              : productCtrl
                                                    .filterCategory
                                                    .value,
                                          isSelected:
                                              productCtrl
                                                  .filterCategory
                                                  .value !=
                                              'All',
                                          onPressed: () =>
                                              _openFilterBottomSheet(
                                                context,
                                                'category',
                                                productCtrl,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Obx(
                                    () => Text(
                                      '${productCtrl.filteredItems.length} ${'Products'.tr}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      SliverFillRemaining(
                        child: Obx(() {
                          final loading = productCtrl.isLoading.value;
                          final error = productCtrl.loadError.value;
                          final items = productCtrl.filteredItems.toList();
                          if (loading && productCtrl.products.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (loading)
                                const LinearProgressIndicator(minHeight: 2),
                              if (error.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Wrap(
                                    spacing: 12,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('Could not load products'.tr),
                                      TextButton(
                                        onPressed: loading
                                            ? null
                                            : productCtrl.getProducts,
                                        child: Text('Retry'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: items.isEmpty
                                    ? SingleChildScrollView(
                                        child: _emptyState(context, error),
                                      )
                                    : LayoutBuilder(
                                        builder: (context, content) {
                                          // Text scale above 1.3 clips the
                                          // wide table cells, so fall back to
                                          // cards there.
                                          final table =
                                              content.maxWidth >= 800 &&
                                              MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(16) <=
                                                  20.8;
                                          return RefreshIndicator(
                                            onRefresh: productCtrl.getProducts,
                                            child: table
                                                ? SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    child: ProductTableWidget(
                                                      items: items,
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: items.length,
                                                    itemBuilder: (_, i) =>
                                                        ProductCardWidget(
                                                          product: items[i],
                                                        ),
                                                  ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final isSearching = productCtrl.searchQuery.value.isNotEmpty;
    final hasFilters = productCtrl.hasActiveFilters;

    final IconData icon;
    final String message;
    if (error.isNotEmpty) {
      icon = Icons.cloud_off;
      message = '';
    } else if (isSearching) {
      icon = Icons.search_off;
      message = 'No products found';
    } else if (hasFilters) {
      icon = Icons.filter_alt_off;
      message = 'No products match the selected filter';
    } else {
      icon = Icons.inventory_2_outlined;
      message = 'No products available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (!isSearching && hasFilters)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: productCtrl.clearFilters,
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: Text('Clear filters'.tr),
              ),
            ),
        ],
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
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing:
                                (type == 'category' &&
                                        ctrl.filterCategory.value == opt) ||
                                    (type == 'status' &&
                                        ctrl.selectedStatus.value == opt) ||
                                    (type == 'recency' &&
                                        ctrl.selectedRecency.value == opt)
                                ? Icon(
                                    Icons.check,
                                    color: theme.colorScheme.primary,
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
      ),
      isScrollControlled: true,
    );
  }
}
