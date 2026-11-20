import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_card_widget.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_table_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:get/get.dart';

class SaleListScreen extends StatelessWidget {
  SaleListScreen({super.key});
  final ctr = Get.isRegistered<SaleListController>()
      ? Get.find<SaleListController>()
      : Get.put(SaleListController());

  @override
  Widget build(BuildContext context) {
    final desktop = DesktopAppShell.isVisible(context);
    final shortViewport =
        MediaQuery.sizeOf(context).height < AppTokens.bpSaleShellMinHeight;
    final newSale = FilledButton.icon(
      onPressed: ctr.onNewSale,
      icon: const Icon(Icons.add),
      label: Text('New Sale'.tr),
    );
    final refresh = IconButton.outlined(
      tooltip: 'Refresh'.tr,
      onPressed: ctr.onRefresh,
      icon: const Icon(Icons.refresh),
    );

    return Scaffold(
      appBar: desktop
          ? null
          : CustomAppBar(
              title: 'Sale List',
              onBack: () => _back(context),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: IconButton(
                    tooltip: 'Refresh'.tr,
                    onPressed: ctr.onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
      body: AppPage(
        verticalGutter: desktop ? null : AppSpacing.md,
        child: LayoutBuilder(
          builder: (context, bounds) => RefreshIndicator(
            onRefresh: ctr.onRefresh,
            child: Obx(() {
              final rows = ctr.filteredSaleList;
              final loading = ctr.isLoading.value;
              final error = ctr.loadError.value;
              final initialPending =
                  ctr.saleList.isEmpty && (loading || error.isNotEmpty);
              final largeText =
                  MediaQuery.textScalerOf(context).scale(
                    Theme.of(context).textTheme.bodyMedium?.fontSize ??
                        AppSpacing.lg,
                  ) >
                  AppTokens.tableMaxScaledBodySize;
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (desktop)
                          AppPageHeader(
                            title: 'Sale List',
                            compactActionsAlignment: Alignment.centerLeft,
                            leading: IconButton.outlined(
                              tooltip: 'Back'.tr,
                              onPressed: () => _back(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            actions: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [newSale, refresh],
                            ),
                          )
                        else
                          newSale,
                        const SizedBox(height: AppSpacing.lg),
                        AppSearchField(
                          title: 'Search Sale',
                          searchController: ctr.searchCtr,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (error.isNotEmpty)
                          Semantics(
                            liveRegion: true,
                            child: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.sm,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(error.tr),
                                TextButton(
                                  onPressed: ctr.onRefresh,
                                  child: Text('Retry'.tr),
                                ),
                              ],
                            ),
                          ),
                        if (loading) const LinearProgressIndicator(),
                      ],
                    ),
                  ),
                  if (rows.isEmpty && !initialPending)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          AppEmptyState(
                            message: ctr.saleList.isEmpty
                                ? 'No Sale Found'
                                : 'No matching sales',
                          ),
                          if (ctr.searchCtr.keyword.value.isNotEmpty)
                            TextButton(
                              onPressed: ctr.searchCtr.clear,
                              child: Text('Clear search'.tr),
                            ),
                        ],
                      ),
                    )
                  else if (rows.isNotEmpty &&
                      bounds.maxWidth >= AppTokens.bpTable &&
                      !shortViewport &&
                      !largeText)
                    SliverToBoxAdapter(
                      child: SaleTableWidget(
                        sales: rows,
                        onOpen: ctr.gotoSaleListDetail,
                      ),
                    )
                  else if (rows.isNotEmpty)
                    SliverList.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, index) => SaleCardWidget(
                        sale: rows[index],
                        onTap: () => ctr.gotoSaleListDetail(rows[index]),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) => Navigator.of(context).canPop()
      ? Get.back()
      : Get.offNamed(AppRoutes.home);
}
