import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_widget.dart';
import 'package:frontend/screen/purchase_request/widget/purchase_request_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchaseRequestScreen extends StatelessWidget {
  PurchaseRequestScreen({super.key});
  final ctr = Get.find<PurchaseRequestController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'Purchase Requests', useTheme: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.all(gutter),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  'Purchase Requests'.tr,
                                                  style: theme
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                        'Manage purchase requests.'.tr,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh, size: 20),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          ctr.addPurchaseRequest(context),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 48),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add, size: 20),
                                      label: Text('Add Purchase Request'.tr),
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
                                    width: content.maxWidth < 420
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
                                        title: 'Search Purchase Requests',
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '${ctr.searchRequestList.length} ${'Purchase Requests'.tr}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
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
                          final loading = ctr.isLoading.value;
                          final error = ctr.loadError.value;
                          final items = ctr.searchRequestList.toList();
                          if (loading && ctr.requestList.isEmpty) {
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
                                child: items.isEmpty
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
                                                Icons.assignment_outlined,
                                                size: 40,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                (ctr.requestList.isEmpty
                                                        ? 'No purchase requests yet'
                                                        : 'No matching purchase requests')
                                                    .tr,
                                                textAlign: TextAlign.center,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 16),
                                              if (ctr.requestList.isEmpty)
                                                FilledButton.icon(
                                                  key: const Key(
                                                    'empty-add-purchase-request',
                                                  ),
                                                  onPressed: () =>
                                                      ctr.addPurchaseRequest(
                                                        context,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                  label: Text(
                                                    'Add Purchase Request'.tr,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  'Try a different search or clear the filter.'
                                                      .tr,
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
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
                                                    child:
                                                        PurchaseRequestTableWidget(
                                                          requests: items,
                                                        ),
                                                  )
                                                : ListView.builder(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: items.length,
                                                    itemBuilder: (_, i) =>
                                                        CardPurchaseRequestWidget(
                                                          purchaseRequest:
                                                              items[i],
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
