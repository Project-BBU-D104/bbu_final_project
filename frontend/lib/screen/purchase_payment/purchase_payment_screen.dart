import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_card_widget.dart';
import 'package:frontend/screen/purchase_payment/widget/purchase_payment_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class PurchasePaymentScreen extends StatelessWidget {
  PurchasePaymentScreen({super.key});

  final ctr = Get.find<PurchasePaymentController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'Purchase Payments', useTheme: true),
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
                                            'Purchase Payments'.tr,
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
                                  'Manage purchase payments.'.tr,
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
                                onPressed: () =>
                                    ctr.addPurchasePayment(context),
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
                                label: Text('Add Purchase Payment'.tr),
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
                                  title: 'Search Purchase Payments',
                                ),
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${ctr.searchPaymentList.length} '
                                '${'Purchase Payments'.tr}',
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
                          if (ctr.isLoading.value &&
                              ctr.purchasePaymentList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final error = ctr.loadError.value;
                          final payments = ctr.searchPaymentList.toList();
                          if (payments.isEmpty) {
                            if (error.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(error, textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: ctr.isLoading.value
                                          ? null
                                          : ctr.onRefresh,
                                      child: Text('Retry'.tr),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 56,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        size: 40,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        (ctr.purchasePaymentList.isEmpty
                                                ? 'No purchase payments yet'
                                                : 'No matching purchase payments')
                                            .tr,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 20),
                                      FilledButton.icon(
                                        key: const Key(
                                          'empty-add-purchase-payment',
                                        ),
                                        onPressed: () =>
                                            ctr.addPurchasePayment(context),
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(0, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add, size: 20),
                                        label: Text('Add Purchase Payment'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              if (ctr.isLoading.value)
                                const LinearProgressIndicator(minHeight: 2),
                              if (error.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          error,
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: ctr.isLoading.value
                                            ? null
                                            : ctr.onRefresh,
                                        child: Text('Retry'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: LayoutBuilder(
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
                                              child: PurchasePaymentTableWidget(
                                                payments: payments,
                                                onEdit: (payment) =>
                                                    ctr.editPurchasePayment(
                                                      context,
                                                      payment,
                                                    ),
                                                onDelete: (payment) {
                                                  final id = int.tryParse(
                                                    payment['id']?.toString() ??
                                                        '',
                                                  );
                                                  if (id != null) {
                                                    ctr.onDeletePurchasePayment(
                                                      context,
                                                      id,
                                                    );
                                                  }
                                                },
                                              ),
                                            )
                                          : ListView.builder(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              itemCount: payments.length,
                                              itemBuilder: (context, index) {
                                                final payment = payments[index];
                                                final id = int.tryParse(
                                                  payment['id']?.toString() ??
                                                      '',
                                                );
                                                return PurchasePaymentCardWidget(
                                                  payment: payment,
                                                  onEdit: () =>
                                                      ctr.editPurchasePayment(
                                                        context,
                                                        payment,
                                                      ),
                                                  onDelete: id == null
                                                      ? null
                                                      : () => ctr
                                                            .onDeletePurchasePayment(
                                                              context,
                                                              id,
                                                            ),
                                                );
                                              },
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
