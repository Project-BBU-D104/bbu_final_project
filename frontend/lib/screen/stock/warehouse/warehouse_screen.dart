import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_card_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_table_widget.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class WarehouseScreen extends StatelessWidget {
  WarehouseScreen({super.key});
  final ctr = Get.find<WarehouseController>();
  final _searchReset = 0.obs;
  @override
  Widget build(BuildContext context) {
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop ? null : const CustomAppBar(title: 'Warehouses'),
      body: AppPage(
        child: LayoutBuilder(
          builder: (context, constraints) => Obx(() {
            final loading = ctr.isLoading.value;
            final error = ctr.loadError.value;
            final items = ctr.searchWarehouseList.toList();
            final table =
                constraints.maxWidth >= AppTokens.bpTable &&
                MediaQuery.textScalerOf(context).scale(16) <=
                    AppTokens.tableMaxScaledBodySize;
            final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
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
                          title: 'Warehouses',
                          subtitle: 'Manage warehouse locations and stock.',
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
                                onPressed: busy
                                    ? null
                                    : () => ctr.addWarehouse(context),
                                icon: const Icon(Icons.add),
                                label: Text('Add Warehouse'.tr),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Wrap(
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.md,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:
                                  constraints.maxWidth < AppTokens.bpSearchField
                                  ? constraints.maxWidth
                                  : AppTokens.bpSearchField,
                              child: Obx(
                                () => AppSearchField(
                                  key: ValueKey(_searchReset.value),
                                  title: 'Search Warehouses',
                                ),
                              ),
                            ),
                            Text('${items.length} ${'Warehouses'.tr}'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (loading) const LinearProgressIndicator(),
                        if (error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  liveRegion: true,
                                  child: Text(error.tr),
                                ),
                                TextButton(
                                  onPressed: loading ? null : ctr.onRefresh,
                                  child: Text('Retry'.tr),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (items.isEmpty && !loading && error.isEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppEmptyState(
                            message: ctr.warehouseList.isEmpty
                                ? 'No warehouses yet'
                                : 'No matching warehouses',
                            icon: Icons.warehouse_outlined,
                          ),
                          if (ctr.searchQuery.value.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Get.find<SearchController>().clear();
                                _searchReset.value++;
                              },
                              child: Text('Clear search'.tr),
                            ),
                        ],
                      ),
                    ),
                  if (items.isNotEmpty)
                    if (table)
                      SliverToBoxAdapter(
                        child: WarehouseTableWidget(warehouses: items),
                      )
                    else
                      SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            WarehouseCardWidget(warehouse: items[index]),
                      ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
