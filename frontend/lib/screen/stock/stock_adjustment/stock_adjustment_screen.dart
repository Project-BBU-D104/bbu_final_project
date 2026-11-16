import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'widget/stock_adjustment_card_widget.dart';
import 'widget/stock_adjustment_table_widget.dart';

class StockAdjustmentScreen extends StatelessWidget {
  StockAdjustmentScreen({super.key});
  final ctr = Get.find<StockAdjustmentController>();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopAppShell.isVisible(context)
        ? null
        : const CustomAppBar(title: 'Stock Adjustment'),
    body: AppPage(
      child: LayoutBuilder(
        builder: (context, content) => Obx(() {
          final loading = ctr.isLoading.value;
          final error = ctr.loadError.value;
          final formError = ctr.formError.value;
          final records = ctr.searchStockAdjustmentList.toList();
          final empty = ctr.stockAdjustmentList.isEmpty;
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
                        title: 'Stock Adjustment',
                        subtitle:
                            'Review stock corrections and their quantities.',
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
                                  : () => ctr.addStockAdjustment(context),
                              icon: const Icon(Icons.add),
                              label: Text('Add Stock Adjustment'.tr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppSearchField(title: 'Search Stock Adjustment'),
                      const SizedBox(height: AppSpacing.md),
                      Text('${records.length} ${'Stock adjustments'.tr}'),
                      const SizedBox(height: AppSpacing.lg),
                      if (loading) const LinearProgressIndicator(),
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
                      if (formError.isNotEmpty)
                        Semantics(liveRegion: true, child: Text(formError.tr)),
                    ],
                  ),
                ),
                if (empty && loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (records.isEmpty)
                  SliverToBoxAdapter(
                    child: AppEmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: error.isNotEmpty && empty
                          ? 'Unable to load stock adjustments. Please try again.'
                          : empty
                          ? 'No stock adjustments yet'
                          : 'No matching stock adjustments',
                    ),
                  )
                else if (table)
                  SliverToBoxAdapter(
                    child: StockAdjustmentTableWidget(
                      stockAdjustments: records,
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: records.length,
                    itemBuilder: (_, index) => StockAdjustmentCardWidget(
                      stockAdjustment: records[index],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
