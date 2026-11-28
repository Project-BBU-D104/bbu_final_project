import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';
import 'package:frontend/screen/sale/widget/payment_footer_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:get/get.dart';

class SaleScreen extends StatelessWidget {
  SaleScreen({super.key});
  final ctr = Get.find<SaleController>();
  // Preserve focus when search moves out of the scroll view above the keyboard.
  final _searchKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight =
        viewportHeight - keyboardHeight - MediaQuery.viewPaddingOf(context).top;
    final desktop = DesktopAppShell.isVisible(context);
    final shortViewport =
        viewportHeight < AppTokens.bpSaleShellMinHeight && !desktop;
    final shortKeyboard =
        keyboardHeight > 0 &&
        availableHeight < kToolbarHeight + 5 * AppTokens.controlHeight &&
        !desktop;
    final hideToolbar =
        shortKeyboard &&
        availableHeight < kToolbarHeight + 2 * AppTokens.controlHeight;
    final search = LayoutBuilder(
      key: _searchKey,
      builder: (context, bounds) => Row(
        children: [
          Expanded(
            child: AppSearchField(
              title: 'Search',
              showScan: true,
              searchController: ctr.searchCtr,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Obx(() {
            final grid =
                ctr.productGridView.value ??
                !_usesListByDefault(context, bounds.maxWidth, shortViewport);
            final maxColumns = _maxGridColumns(bounds.maxWidth);
            final columns = _gridColumns(bounds.maxWidth, grid);
            return PopupMenuButton<int>(
              tooltip: 'Layout'.tr,
              icon: const Icon(Icons.view_quilt_outlined),
              onSelected: (value) {
                ctr.setProductLayout(
                  grid: value != 0,
                  columns: value >= 2 ? value : null,
                );
              },
              itemBuilder: (context) => [
                CheckedPopupMenuItem<int>(
                  value: 0,
                  checked: !grid,
                  child: Text('List view'.tr),
                ),
                CheckedPopupMenuItem<int>(
                  value: 1,
                  checked: grid,
                  child: Text('Grid view'.tr),
                ),
                const PopupMenuDivider(),
                for (
                  var count = 2;
                  count <= AppTokens.saleGridMaxColumns;
                  count++
                )
                  CheckedPopupMenuItem<int>(
                    value: count,
                    enabled: count <= maxColumns,
                    checked: grid && count == columns,
                    child: Text('@count columns'.trParams({'count': '$count'})),
                  ),
              ],
            );
          }),
        ],
      ),
    );
    final page = Scaffold(
      appBar: hideToolbar || desktop
          ? null
          : CustomAppBar(title: 'Sale', onBack: () => _back(context)),
      body: AppPage(
        verticalGutter: shortKeyboard ? AppSpacing.sm : null,
        child: Column(
          children: [
            if (shortKeyboard) search,
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, bounds) => Obx(() {
                      final groups = ctr.filteredCategories;
                      final count = groups.fold<int>(
                        0,
                        (n, c) => n + (c['products'] as List? ?? []).length,
                      );
                      final defaultList = _usesListByDefault(
                        context,
                        bounds.maxWidth,
                        shortViewport,
                      );
                      final grid = ctr.productGridView.value ?? !defaultList;
                      final columns = _gridColumns(bounds.maxWidth, grid);
                      return CustomScrollView(
                        slivers: [
                          if (!shortKeyboard)
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (desktop) ...[
                                    AppPageHeader(
                                      title: 'Sale',
                                      compactActionsAlignment:
                                          Alignment.centerLeft,
                                      leading: IconButton.outlined(
                                        tooltip: 'Back'.tr,
                                        onPressed: () => _back(context),
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                  search,
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                              ),
                            ),
                          if (ctr.isLoading.value && ctr.categories.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (ctr.productLoadError.value.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  Text(ctr.productLoadError.value),
                                  TextButton(
                                    onPressed: ctr.loadProductCategories,
                                    child: Text('Retry'.tr),
                                  ),
                                ],
                              ),
                            ),
                          if (!ctr.isLoading.value &&
                              count == 0 &&
                              (ctr.productLoadError.value.isEmpty ||
                                  ctr.categories.isNotEmpty))
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  AppEmptyState(
                                    message: ctr.searchCtr.keyword.value.isEmpty
                                        ? 'No products available'
                                        : 'No products found',
                                    icon: Icons.inventory_2_outlined,
                                  ),
                                  if (ctr.searchCtr.keyword.value.isNotEmpty)
                                    TextButton(
                                      onPressed: ctr.searchCtr.clear,
                                      child: Text('Clear search'.tr),
                                    ),
                                ],
                              ),
                            ),
                          for (final group in groups) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Text(group['name']?.toString() ?? ''),
                              ),
                            ),
                            if (!grid)
                              SliverList.separated(
                                itemCount:
                                    (group['products'] as List? ?? []).length,
                                itemBuilder: (context, index) =>
                                    _tile((group['products'] as List)[index]),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                              )
                            else if (ctr.productGridView.value == true)
                              SliverList.separated(
                                itemCount:
                                    ((group['products'] as List? ?? []).length +
                                        columns -
                                        1) ~/
                                    columns,
                                itemBuilder: (context, row) {
                                  final products = group['products'] as List;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (
                                        var column = 0;
                                        column < columns;
                                        column++
                                      ) ...[
                                        if (column > 0)
                                          const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child:
                                              row * columns + column <
                                                  products.length
                                              ? _tile(
                                                  products[row * columns +
                                                      column],
                                                  naturalGrid: true,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.md),
                              )
                            else
                              SliverGrid.builder(
                                itemCount:
                                    (group['products'] as List? ?? []).length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      childAspectRatio:
                                          AppTokens.saleProductTileAspectRatio,
                                      mainAxisSpacing: AppSpacing.md,
                                      crossAxisSpacing: AppSpacing.md,
                                    ),
                                itemBuilder: (context, index) =>
                                    _tile((group['products'] as List)[index]),
                              ),
                          ],
                          if (!shortKeyboard &&
                              !shortViewport &&
                              ctr.totalItems > 0)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height:
                                    AppTokens.controlHeight +
                                    AppSpacing.xxl +
                                    MediaQuery.textScalerOf(context).scale(
                                          Theme.of(context)
                                                  .textTheme
                                                  .labelLarge
                                                  ?.fontSize ??
                                              AppSpacing.lg,
                                        ) *
                                        6,
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                  if (!shortKeyboard && !shortViewport)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Obx(
                        () => ctr.totalItems == 0
                            ? const SizedBox.shrink()
                            : PaymentFooterWidget(
                                onTap: ctr.onCurrentSale,
                                itemCount: ctr.totalItems,
                                total: ctr.subtotal,
                                currency: ctr.currency.value,
                                usdToKhrRate: ctr.usdToKhrRate,
                              ),
                      ),
                    ),
                ],
              ),
            ),
            if (shortViewport && !shortKeyboard)
              Obx(
                () => ctr.totalItems == 0
                    ? const SizedBox.shrink()
                    : PaymentFooterWidget(
                        onTap: ctr.onCurrentSale,
                        itemCount: ctr.totalItems,
                        total: ctr.subtotal,
                        currency: ctr.currency.value,
                        usdToKhrRate: ctr.usdToKhrRate,
                      ),
              ),
          ],
        ),
      ),
    );
    return Obx(
      () => PopScope(
        canPop: ctr.cart.isEmpty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _back(context);
        },
        child: page,
      ),
    );
  }

  Future<void> _back(BuildContext context) async {
    if (ctr.cart.isNotEmpty) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Confirm'.tr),
          content: Text(
            'You have selected products. Are you sure you want to exit?'.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel'.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Leave'.tr),
            ),
          ],
        ),
      );
      if (leave != true || !context.mounted) return;
    }
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.home);
    }
  }

  bool _usesListByDefault(BuildContext context, double width, bool short) =>
      short ||
      width < AppTokens.bpSearchField ||
      MediaQuery.textScalerOf(context).scale(
            Theme.of(context).textTheme.bodyMedium?.fontSize ?? AppSpacing.lg,
          ) >
          AppTokens.tableMaxScaledBodySize;

  int _maxGridColumns(double width) =>
      ((width + AppSpacing.md) /
              (AppTokens.saleGridMinTileWidth + AppSpacing.md))
          .floor()
          .clamp(1, AppTokens.saleGridMaxColumns);

  int _gridColumns(double width, bool grid) {
    final preferred = ctr.productGridView.value == null && grid
        ? ((width + AppSpacing.md) /
                  (AppTokens.saleProductTileMaxExtent + AppSpacing.md))
              .ceil()
        : ctr.productGridColumns.value;
    return preferred.clamp(1, _maxGridColumns(width));
  }

  Widget _tile(Map<String, dynamic> product, {bool naturalGrid = false}) => Obx(
    () => CardItemWidget(
      product: product,
      quantity: ctr.cart[product['id']]?['qty'] as int? ?? 0,
      currency: ctr.currencyForProduct(product),
      naturalGrid: naturalGrid,
      onTap: () => ctr.addProduct(product),
    ),
  );
}
