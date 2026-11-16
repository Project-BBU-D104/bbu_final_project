import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_table_widget.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockTransferScreen extends StatelessWidget {
  StockTransferScreen({super.key});
  final ctr = Get.find<ProductTransferController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopAppShell.isVisible(context)
        ? null
        : const CustomAppBar(title: 'Stock Transfer'),
    body: AppPage(
      child: LayoutBuilder(
        builder: (context, content) => Obx(() {
          final items = ctr.searchStockTransferList.toList();
          final loading = ctr.isLoading.value;
          final error = ctr.loadError.value;
          final table =
              content.maxWidth >= AppTokens.bpTable &&
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
                        title: 'Stock Transfer',
                        subtitle: 'Manage stock movements between warehouses.',
                        leading: DesktopAppShell.isVisible(context)
                            ? IconButton.outlined(
                                tooltip: 'Back'.tr,
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back),
                              )
                            : null,
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
                              onPressed: ctr.isSaving.value
                                  ? null
                                  : () => ctr.addStockTransfer(context),
                              icon: const Icon(Icons.add),
                              label: Text('Add Stock Transfer'.tr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppSearchField(title: 'Search Stock Transfer'),
                      const SizedBox(height: AppSpacing.md),
                      Text('${items.length} ${'Stock Transfer'.tr}'),
                      const SizedBox(height: AppSpacing.lg),
                      if (loading && ctr.stockTransfer.isNotEmpty)
                        const LinearProgressIndicator(),
                      if (error.isNotEmpty)
                        Wrap(
                          spacing: AppSpacing.md,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(error.tr),
                            TextButton(
                              onPressed: loading ? null : ctr.onRefresh,
                              child: Text('Retry'.tr),
                            ),
                          ],
                        ),
                      if (ctr.formError.isNotEmpty)
                        Text(ctr.formError.value.tr),
                    ],
                  ),
                ),
                if (loading && ctr.stockTransfer.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      message: error.isNotEmpty
                          ? ''
                          : ctr.stockTransfer.isEmpty
                          ? 'No stock transfers yet'
                          : 'No matching stock transfers',
                    ),
                  )
                else if (table)
                  SliverToBoxAdapter(
                    child: StockTransferTableWidget(stockTransfers: items),
                  )
                else
                  SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) =>
                        StockTransferCardWidget(stockTransfer: items[index]),
                  ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
