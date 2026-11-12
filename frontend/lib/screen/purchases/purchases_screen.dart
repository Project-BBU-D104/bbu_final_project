import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/purchases/widget/purchase_card_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchasesScreen extends StatelessWidget {
  PurchasesScreen({super.key});
  final ctr = Get.find<PurchaseController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'Purchases', useTheme: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.all(gutter),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            'Purchases'.tr,
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
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
                                  'Manage purchases.'.tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                                onPressed: ctr.onRefresh,
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  side: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.12),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh, size: 20),
                              ),
                              FilledButton.icon(
                                onPressed: () => ctr.addPurchase(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add, size: 20),
                                label: Text('Add Purchase'.tr),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const SearchWidget(
                                  title: 'Search Purchases...',
                                ),
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${ctr.searchPurchaseList.length} ${'Purchases'.tr}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Obx(() {
                          final loading = ctr.isLoading.value;
                          final error = ctr.loadError.value;
                          final purchases = ctr.searchPurchaseList.toList();
                          if (loading && ctr.purchaseList.isEmpty) {
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
                                      Text(error),
                                      TextButton(
                                        onPressed: loading
                                            ? null
                                            : ctr.onRefresh,
                                        child: Text('Retry'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: purchases.isEmpty
                                    ? SingleChildScrollView(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 56,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.cardColor,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.08),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 40,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                error.isNotEmpty
                                                    ? ''
                                                    : (ctr.purchaseList.isEmpty
                                                              ? 'No purchases yet'
                                                              : 'No matching purchases')
                                                          .tr,
                                                textAlign: TextAlign.center,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                              if (error.isEmpty) ...[
                                                const SizedBox(height: 20),
                                                FilledButton.icon(
                                                  key: const Key(
                                                    'empty-add-purchase',
                                                  ),
                                                  onPressed: () =>
                                                      ctr.addPurchase(context),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                  label: Text(
                                                    'Add Purchase'.tr,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      )
                                    : LayoutBuilder(
                                        builder: (context, content) {
                                          final table =
                                              content.maxWidth >= 800 &&
                                              MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(16) <=
                                                  20.8;
                                          return RefreshIndicator(
                                            onRefresh: ctr.onRefresh,
                                            child: table
                                                ? SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    child: PurchaseTableWidget(
                                                      purchases: purchases,
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: purchases.length,
                                                    itemBuilder: (_, i) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 12,
                                                          ),
                                                      child: PurchaseCardWidget(
                                                        purchase: purchases[i],
                                                      ),
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
}
