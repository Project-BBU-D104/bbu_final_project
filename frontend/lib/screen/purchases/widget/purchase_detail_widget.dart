import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';

class PurchaseDetailWidget extends StatelessWidget {
  PurchaseDetailWidget({super.key});

  final Map<String, dynamic>? _purchase = Get.arguments is Map<String, dynamic>
      ? Get.arguments as Map<String, dynamic>
      : null;

  final ctr = Get.isRegistered<PurchaseController>()
      ? Get.find<PurchaseController>()
      : Get.put(PurchaseController());

  String _formatCurrency(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(number);
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'active':
        return colors.primary;
      case 'partial':
      case 'pending':
        return colors.tertiary;
      case 'due':
      case 'unpaid':
      case 'inactive':
        return colors.error;
      default:
        return colors.onSurfaceVariant;
    }
  }

  String _statusLabel(dynamic raw) {
    final status = (raw ?? '').toString().trim();
    if (status.isEmpty) return '';
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid'.tr;
      case 'partial':
        return 'Partial'.tr;
      case 'unpaid':
        return 'Unpaid'.tr;
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final original = _purchase;
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    final appBar = desktop
        ? null
        : const CustomAppBar(title: 'Purchase Detail', useTheme: true);

    if (original == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: Text('No purchase data found'.tr)),
      );
    }

    return Obx(() {
      final current = ctr.purchaseList.firstWhere(
        (p) => p['id'] == original['id'],
        orElse: () => original,
      );
      final colors = theme.colorScheme;
      final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
      final error = ctr.formError.value;
      final supplier = current['supplier'] is Map
          ? current['supplier']['name']?.toString()
          : null;
      final user = current['user'] is Map
          ? current['user']['name']?.toString()
          : null;
      final items = current['purchase_items'] is List
          ? current['purchase_items'] as List
          : const [];
      final paymentStatus = _statusLabel(current['payment_status']);
      final status = _statusLabel(current['status']);
      final description = current['description']?.toString().trim() ?? '';
      final actions = _actions(context, current, busy);

      Widget info(String label, String? value) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              (value ?? '').trim().isEmpty ? '-' : value!.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

      Widget chip(String raw, String label) {
        if (label.isEmpty) return const SizedBox.shrink();
        final color = _statusColor(context, raw);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      final header = HomeSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  current['invoice_no']?.toString() ?? '-',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                chip(
                  current['payment_status']?.toString() ?? '',
                  paymentStatus,
                ),
                chip(current['status']?.toString() ?? '', status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(current['purchase_date']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      );

      final details = HomeSectionCard(
        title: 'Purchase details',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            info('Supplier', supplier),
            const Divider(height: 1),
            const SizedBox(height: 16),
            info('Created By', user),
          ],
        ),
      );

      final itemsCard = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'Items'.tr} (${items.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          HomeSectionCard(
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No items in this purchase'.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (items[i] is Map)
                          _itemRow(
                            context,
                            Map<String, dynamic>.from(items[i] as Map),
                          ),
                        if (i != items.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ],
                  ),
          ),
        ],
      );

      final summary = HomeSectionCard(
        child: Column(
          children: [
            _summaryRow(context, 'Subtotal', current['subtotal']),
            _summaryRow(context, 'Tax', current['tax_amount']),
            _summaryRow(context, 'Discount', current['discount_amount']),
            const Divider(height: 20),
            _summaryRow(context, 'Total', current['total_amount'], bold: true),
            _summaryRow(context, 'Paid', current['paid_amount']),
            _summaryRow(
              context,
              'Due',
              current['due_amount'],
              valueColor:
                  (double.tryParse(current['due_amount']?.toString() ?? '0') ??
                          0) >
                      0
                  ? colors.error
                  : null,
            ),
          ],
        ),
      );

      return Scaffold(
        appBar: appBar,
        body: HomeTabLayout(
          title: current['invoice_no']?.toString() ?? '-',
          translateTitle: false,
          subtitle: 'Purchase Detail',
          leading: desktop
              ? IconButton.outlined(
                  tooltip: 'Back'.tr,
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, size: 20),
                )
              : null,
          action: desktop ? actions : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(error, style: TextStyle(color: colors.error)),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              header,
                              const SizedBox(height: 24),
                              details,
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              itemsCard,
                              const SizedBox(height: 24),
                              summary,
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      const SizedBox(height: 24),
                      details,
                      const SizedBox(height: 24),
                      itemsCard,
                      const SizedBox(height: 24),
                      summary,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: desktop
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: actions,
                ),
              ),
      );
    });
  }

  Widget _actions(
    BuildContext context,
    Map<String, dynamic> purchase,
    bool busy,
  ) {
    final id = purchase['id'];
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: busy || id is! int
              ? null
              : () => ctr.deletePurchase(
                  context: context,
                  purchaseId: id,
                  onDeleted: () => Get.back(),
                ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 48),
            foregroundColor: colors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text('Delete'.tr),
        ),
        FilledButton.icon(
          onPressed: busy || id is! int
              ? null
              : () => ctr.editPurchase(context, id),
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('Edit'.tr),
        ),
      ],
    );
  }

  Widget _itemRow(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final product = item['product'];
    final name = product is Map
        ? (product['name'] ?? '').toString().trim()
        : '';
    final qty = item['qty']?.toString() ?? '0';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '-' : name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qty x ${_formatCurrency(item['cost_price'])}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(item['subtotal']),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    dynamic value, {
    bool bold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatCurrency(value),
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
