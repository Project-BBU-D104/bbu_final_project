import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/supplier/widgets/supplier_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_table_widget.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SupplierScreen extends StatelessWidget {
  SupplierScreen({super.key});
  final controller = Get.find<SupplierController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop ? null : const CustomAppBar(title: 'Suppliers'),
      body: AppPage(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Suppliers',
                    subtitle: 'Manage supplier contacts and locations.',
                    leading: desktop
                        ? IconButton.outlined(
                            tooltip: 'Back'.tr,
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back, size: 20),
                          )
                        : null,
                    actions: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        IconButton.outlined(
                          tooltip: 'Refresh'.tr,
                          onPressed: controller.onRefresh,
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusControl,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 20),
                        ),
                        FilledButton.icon(
                          onPressed: () => controller.addSupplier(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text('Add Supplier'.tr),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, content) => Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: content.maxWidth < AppTokens.bpSearchField
                              ? content.maxWidth
                              : 420,
                          child: const AppSearchField(
                            title: 'Search Suppliers',
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${controller.searchSuppliers.length} ${'Suppliers'.tr}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                final loading = controller.isLoading.value;
                final error = controller.loadError.value;
                final items = controller.searchSuppliers.toList();
                if (loading && controller.suppliers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
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
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(error),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : controller.onRefresh,
                              child: Text('Retry'.tr),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: items.isEmpty
                          ? SingleChildScrollView(
                              child: AppEmptyState(
                                message: error.isNotEmpty
                                    ? ''
                                    : (controller.suppliers.isEmpty
                                          ? 'No suppliers yet'
                                          : 'No matching suppliers'),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, content) {
                                final table =
                                    content.maxWidth >= AppTokens.bpTable &&
                                    MediaQuery.textScalerOf(
                                      context,
                                    ).scale(16) <=
                                        20.8;
                                return RefreshIndicator(
                                  onRefresh: controller.onRefresh,
                                  child: table
                                      ? SingleChildScrollView(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          child: SupplierTableWidget(
                                            items: items,
                                          ),
                                        )
                                      : ListView.builder(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: items.length,
                                          itemBuilder: (_, i) =>
                                              SupplierCardWidget(
                                                item: items[i],
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
    );
  }
}
