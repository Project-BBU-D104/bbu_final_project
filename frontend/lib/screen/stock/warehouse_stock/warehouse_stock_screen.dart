import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'widget/warehouse_stock_card_widget.dart';
import 'widget/warehouse_stock_table_widget.dart';

class WarehouseStockScreen extends StatelessWidget {
  WarehouseStockScreen({super.key});
  final ctr = Get.find<WarehouseStockController>();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopAppShell.isVisible(context)
        ? null
        : const CustomAppBar(title: 'Warehouse Stock'),
    body: AppPage(
      child: LayoutBuilder(
        builder: (context, constraints) => Obx(() {
          final loading = ctr.isLoading.value;
          final error = ctr.loadError.value;
          final rows = ctr.searchwarehouseStockList.toList();
          final table =
              constraints.maxWidth >= AppTokens.bpTable &&
              MediaQuery.textScalerOf(context).scale(16) <=
                  AppTokens.tableMaxScaledBodySize;
          return RefreshIndicator(
            onRefresh: ctr.onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPageHeader(
                        title: 'Warehouse Stock',
                        subtitle:
                            'Manage products and quantities by warehouse.',
                        actions: Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            IconButton.outlined(
                              tooltip: 'Refresh'.tr,
                              onPressed: loading ? null : ctr.onRefresh,
                              icon: const Icon(Icons.refresh),
                            ),
                            FilledButton.icon(
                              onPressed:
                                  ctr.isSaving.value || ctr.isOpeningEdit.value
                                  ? null
                                  : () => ctr.addWarehouseStock(context),
                              icon: const Icon(Icons.add),
                              label: Text('Add Warehouse Stock'.tr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppSearchField(title: 'Search Warehouse Stock'),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.md,
                        children: [
                          Text(
                            '${rows.length} / ${ctr.warehouseStockList.length} ${'Warehouse Stock'.tr}',
                          ),
                          if (ctr.searchQuery.value.isNotEmpty)
                            TextButton(
                              onPressed: () =>
                                  Get.find<SearchController>().clear(),
                              child: Text('Clear search'.tr),
                            ),
                        ],
                      ),
                      if (loading) const LinearProgressIndicator(),
                      if (error.isNotEmpty)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(error),
                            TextButton(
                              onPressed: loading ? null : ctr.onRefresh,
                              child: Text('Retry'.tr),
                            ),
                          ],
                        ),
                      if (ctr.formError.value.isNotEmpty)
                        Text(ctr.formError.value),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
                if (rows.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      message: loading
                          ? 'Loading warehouse stock'
                          : error.isNotEmpty
                          ? 'Warehouse stock unavailable'
                          : ctr.warehouseStockList.isEmpty
                          ? 'No warehouse stock yet'
                          : 'No matching warehouse stock',
                    ),
                  )
                else if (table)
                  SliverToBoxAdapter(
                    child: WarehouseStockTableWidget(warehouseStocks: rows),
                  )
                else
                  SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (_, index) =>
                        WarehouseStockCardWidget(warehouseStock: rows[index]),
                  ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
