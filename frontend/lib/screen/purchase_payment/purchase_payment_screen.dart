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
                                        'Purchase Payments'.tr,
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (desktop) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Manage purchase payments.'.tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Obx(
                                () => Text(
                                  '${ctr.searchPaymentList.length} '
                                  '${'Purchase Payments'.tr}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              IconButton.outlined(
                                tooltip: 'Refresh'.tr,
                                onPressed: ctr.onRefresh,
                                icon: const Icon(Icons.refresh),
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () =>
                                    ctr.addPurchasePayment(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: const Icon(Icons.add),
                                label: Text('Add Purchase Payment'.tr),
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
                          child: SearchWidget(
                            title: 'Search Purchase Payments',
                          ),
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

                          final payments = ctr.searchPaymentList.toList();
                          if (payments.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    size: 56,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    (ctr.purchasePaymentList.isEmpty
                                            ? 'No purchase payments yet'
                                            : 'No matching purchase payments')
                                        .tr,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    key: const Key(
                                      'empty-add-purchase-payment',
                                    ),
                                    onPressed: () =>
                                        ctr.addPurchasePayment(context),
                                    icon: const Icon(Icons.add),
                                    label: Text('Add Purchase Payment'.tr),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              if (ctr.isLoading.value)
                                const LinearProgressIndicator(minHeight: 2),
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
