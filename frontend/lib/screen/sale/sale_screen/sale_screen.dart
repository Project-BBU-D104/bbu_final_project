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
    final search = AppSearchField(
      key: _searchKey,
      title: 'Search',
      showScan: true,
      searchController: ctr.searchCtr,
    );
    return Scaffold(
      appBar: hideToolbar || desktop
          ? null
          : CustomAppBar(title: 'Sale', onBack: () => _back(context)),
      body: AppPage(
        verticalGutter: shortKeyboard ? AppSpacing.sm : null,
        child: Column(
          children: [
            if (shortKeyboard) search,
            Expanded(
              child: LayoutBuilder(
                builder: (context, bounds) => Obx(() {
                  final groups = ctr.filteredCategories;
                  final count = groups.fold<int>(
                    0,
                    (n, c) => n + (c['products'] as List? ?? []).length,
                  );
                  final natural =
                      shortViewport ||
                      bounds.maxWidth < AppTokens.bpSearchField ||
                      MediaQuery.textScalerOf(context).scale(
                            Theme.of(context).textTheme.bodyMedium?.fontSize ??
                                AppSpacing.lg,
                          ) >
                          AppTokens.tableMaxScaledBodySize;
                  return CustomScrollView(
                    slivers: [
                      if (!shortKeyboard)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppPageHeader(
                                title: 'Sale',
                                compactActionsAlignment: Alignment.centerLeft,
                                leading: desktop
                                    ? IconButton.outlined(
                                        tooltip: 'Back'.tr,
                                        onPressed: () => _back(context),
                                        icon: const Icon(Icons.arrow_back),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              search,
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      if (ctr.isLoading.value && ctr.categories.isEmpty)
                        const SliverToBoxAdapter(
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
                        if (natural)
                          SliverList.separated(
                            itemCount:
                                (group['products'] as List? ?? []).length,
                            itemBuilder: (context, index) =>
                                _tile((group['products'] as List)[index]),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                          )
                        else
                          SliverGrid.builder(
                            itemCount:
                                (group['products'] as List? ?? []).length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      AppTokens.saleProductTileMaxExtent,
                                  childAspectRatio:
                                      AppTokens.saleProductTileAspectRatio,
                                  mainAxisSpacing: AppSpacing.md,
                                  crossAxisSpacing: AppSpacing.md,
                                ),
                            itemBuilder: (context, index) =>
                                _tile((group['products'] as List)[index]),
                          ),
                      ],
                    ],
                  );
                }),
              ),
            ),
            if (!shortKeyboard)
              Obx(
                () => ctr.totalItems == 0
                    ? const SizedBox.shrink()
                    : PaymentFooterWidget(
                        onTap: ctr.onCurrentSale,
                        itemCount: ctr.totalItems,
                        total: ctr.subtotal,
                        currency: ctr.currency.value,
                      ),
              ),
          ],
        ),
      ),
    );
  }

  void _back(BuildContext context) => Navigator.of(context).canPop()
      ? Get.back()
      : Get.offNamed(AppRoutes.home);

  Future<void> _selectWarehouse(Map<String, dynamic> product) async {
    final rows = SaleController.warehouses(product);
    if (rows.length == 1) {
      ctr.addProduct(product);
      return;
    }
    final selected = await Get.dialog<int>(
      SimpleDialog(
        title: Text('Select warehouse'.tr),
        children: [
          for (final row in rows)
            ListTile(
              title: Text('${row['warehouse_name']} · ${row['qty']}'),
              enabled:
                  (ctr.cart[(product['id'], row['warehouse_id'])]?['qty'] ??
                      0) <
                  row['qty'],
              onTap: () => Get.back(result: row['warehouse_id']),
            ),
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ],
      ),
    );
    if (selected != null) ctr.addProduct(product, warehouseId: selected);
  }

  Widget _tile(Map<String, dynamic> product) => Obx(
    () => CardItemWidget(
      product: product,
      quantity: ctr.cart.entries
          .where((e) => e.key.$1 == product['id'])
          .fold<int>(0, (sum, e) => sum + (e.value['qty'] as int)),
      currency: ctr.currency.value,
      onTap: ctr.checkoutBusy ? null : () => _selectWarehouse(product),
    ),
  );
}
