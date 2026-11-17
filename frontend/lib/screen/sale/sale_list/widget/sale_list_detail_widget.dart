import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class SaleListDetailWidget extends StatelessWidget {
  const SaleListDetailWidget({super.key});

  Widget _row(String label, String value, {bool translateLabel = true}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          children: [Text(translateLabel ? label.tr : label), Text(value)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sale = saleMap(Get.arguments);
    final desktop = DesktopAppShell.isVisible(context);
    void back() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.offNamed(AppRoutes.home);
      }
    }

    final backControl = desktop
        ? IconButton.outlined(
            tooltip: 'Back'.tr,
            onPressed: back,
            icon: const Icon(Icons.arrow_back),
          )
        : null;
    if (sale.isEmpty) {
      return Scaffold(
        appBar: desktop ? null : CustomAppBar(title: 'Sale', onBack: back),
        body: AppPage(
          child: ListView(
            children: [
              AppPageHeader(
                title: 'Sale',
                leading: backControl,
                compactActionsAlignment: Alignment.centerLeft,
              ),
              const AppEmptyState(message: 'Sale details are unavailable.'),
              TextButton(onPressed: back, child: Text('Back'.tr)),
            ],
          ),
        ),
      );
    }
    final ctr = Get.find<SaleListController>();
    final items = sale['sale_items'] is List
        ? sale['sale_items'] as List
        : const [];
    final invoice = HomeSectionCard(
      title: 'Invoice'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Invoice', saleText(sale['invoice_no'])),
          _row('Customer', saleText(saleMap(sale['customer'])['name'])),
          _row('Phone', saleText(saleMap(sale['customer'])['phone'])),
          _row('Date', formatSaleDate(sale['sale_date'])),
        ],
      ),
    );
    final itemSection = HomeSectionCard(
      title: 'Items'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty) Text('No items'.tr),
          for (final raw in items) ...[
            _row(
              saleText(saleMap(saleMap(raw)['product'])['name']),
              '${saleText(saleMap(raw)['qty'])} × ${formatSaleAmount(saleMap(raw)['sale_price'])}',
              translateLabel: false,
            ),
            _row('Subtotal', formatSaleAmount(saleMap(raw)['subtotal'])),
          ],
        ],
      ),
    );
    final payment = HomeSectionCard(
      title: 'Payment'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Payment Method', saleText(sale['payment_method'])),
          _row('Sale Status', saleText(sale['status'])),
          AppStatusBadge(
            label: salePaymentStatusLabel(sale['payment_status']),
            tone: salePaymentStatusTone(sale['payment_status']),
          ),
          for (final entry in {
            'Subtotal': 'subtotal',
            'Tax': 'tax_amount',
            'Discount': 'discount_amount',
            'Total': 'total_amount',
            'Paid': 'paid_amount',
            'Due': 'due_amount',
          }.entries)
            _row(entry.key, formatSaleAmount(sale[entry.value])),
        ],
      ),
    );
    return Scaffold(
      appBar: desktop ? null : CustomAppBar(title: 'Sale', onBack: back),
      body: AppPage(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Sale',
                leading: backControl,
                compactActionsAlignment: Alignment.centerLeft,
                actions: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    Obx(
                      () => FilledButton.icon(
                        onPressed: ctr.deletingIds.isEmpty
                            ? ctr.onNewSale
                            : null,
                        icon: const Icon(Icons.add),
                        label: Text('New Sale'.tr),
                      ),
                    ),
                    Obx(
                      () => TextButton(
                        onPressed: ctr.deletingIds.contains(sale['id'])
                            ? null
                            : () => ctr.onDeleteSale(sale['id'], context),
                        child: Text('Delete'.tr),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => ctr.loadError.value.isEmpty
                    ? const SizedBox.shrink()
                    : Semantics(
                        liveRegion: true,
                        child: Text(ctr.loadError.value.tr),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, bounds) {
                  final largeText =
                      MediaQuery.textScalerOf(context).scale(
                        Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            AppSpacing.lg,
                      ) >
                      AppTokens.tableMaxScaledBodySize;
                  final left = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      invoice,
                      const SizedBox(height: AppSpacing.lg),
                      itemSection,
                    ],
                  );
                  if (bounds.maxWidth >= AppTokens.bpTwoColumn && !largeText) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: AppSpacing.xxl),
                        Expanded(child: payment),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      left,
                      const SizedBox(height: AppSpacing.lg),
                      payment,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
