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
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopAppShell.isVisible(context)
        ? null
        : CustomAppBar(title: 'Sale', onBack: () => _back(context)),
    body: AppPage(
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, bounds) => Obx(() {
                final groups = ctr.filteredCategories;
                final count = groups.fold<int>(
                  0,
                  (n, c) => n + (c['products'] as List? ?? []).length,
                );
                final natural =
                    bounds.maxWidth < AppTokens.bpSearchField ||
                    MediaQuery.textScalerOf(context).scale(
                          Theme.of(context).textTheme.bodyMedium?.fontSize ??
                              AppSpacing.lg,
                        ) >
                        AppTokens.tableMaxScaledBodySize;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppPageHeader(
                            title: 'Sale',
                            compactActionsAlignment: Alignment.centerLeft,
                            leading: DesktopAppShell.isVisible(context)
                                ? IconButton.outlined(
                                    tooltip: 'Back'.tr,
                                    onPressed: () => _back(context),
                                    icon: const Icon(Icons.arrow_back),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppSearchField(
                            title: 'Search',
                            showScan: true,
                            searchController: ctr.searchCtr,
                          ),
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
                        SliverList.builder(
                          itemCount: (group['products'] as List? ?? []).length,
                          itemBuilder: (context, index) =>
                              _tile((group['products'] as List)[index]),
                        )
                      else
                        SliverGrid.builder(
                          itemCount: (group['products'] as List? ?? []).length,
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
  void _back(BuildContext context) => Navigator.of(context).canPop()
      ? Get.back()
      : Get.offNamed(AppRoutes.home);

  Widget _tile(Map<String, dynamic> product) => Obx(
    () => CardItemWidget(
      product: product,
      quantity: ctr.cart[product['id']]?['qty'] as int? ?? 0,
      currency: ctr.currency.value,
      onTap: () => ctr.addProduct(product),
    ),
  );
}
