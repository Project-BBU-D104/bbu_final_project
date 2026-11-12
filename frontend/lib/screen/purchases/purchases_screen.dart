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
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (desktop)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton.outlined(
                                      tooltip: 'Back'.tr,
                                      onPressed: () => Get.back(),
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                    const SizedBox(width: 12),
                                    Semantics(
                                      header: true,
                                      child: Text(
                                        'Purchases'.tr,
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Obx(
                                () => Text(
                                  '${'Total Purchases'.tr}: ${ctr.purchaseList.length}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 12,
                            children: [
                              IconButton.outlined(
                                tooltip: 'Refresh'.tr,
                                onPressed: ctr.onGetPurchaseList,
                                icon: const Icon(Icons.refresh),
                              ),
                              FilledButton.icon(
                                onPressed: () => ctr.addPurchase(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: const Icon(Icons.add),
                                label: Text('Add Purchase'.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: SearchWidget(title: 'Search Purchases...'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Obx(() {
                          if (ctr.isLoading.value && ctr.purchaseList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final purchases = ctr.searchPurchaseList.toList();
                          if (purchases.isEmpty) {
                            return Center(
                              child: Text(
                                (ctr.purchaseList.isEmpty
                                        ? 'No purchase found'
                                        : 'Search results not found')
                                    .tr,
                                style: theme.textTheme.titleMedium,
                              ),
                            );
                          }
                          return LayoutBuilder(
                            builder: (context, content) {
                              final table =
                                  content.maxWidth >= 800 &&
                                  MediaQuery.textScalerOf(context).scale(16) <=
                                      20.8;
                              return RefreshIndicator(
                                onRefresh: ctr.onGetPurchaseList,
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
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: PurchaseCardWidget(
                                            purchase: purchases[i],
                                          ),
                                        ),
                                      ),
                              );
                            },
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
