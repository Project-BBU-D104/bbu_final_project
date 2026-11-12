import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/screen/purchase_payment/payment_format.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class PurchasePaymentDetailWidget extends StatelessWidget {
  const PurchasePaymentDetailWidget({super.key, required this.payment});

  final Map<String, dynamic> payment;

  String _value(dynamic map, String key) {
    if (map is! Map) return '-';
    final text = (map[key] ?? '').toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Widget _statusChip(BuildContext context, String? raw) {
    final color = paymentStatusColor(context, raw);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        paymentStatusLabel(raw),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _info(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value.trim().isEmpty ? '-' : value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _current(PurchasePaymentController ctr) {
    return ctr.purchasePaymentList.firstWhere(
      (record) => record['id'] == payment['id'],
      orElse: () => payment,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = DesktopAppShell.isVisible(context);
    final ctr = Get.isRegistered<PurchasePaymentController>()
        ? Get.find<PurchasePaymentController>()
        : Get.put(PurchasePaymentController());

    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(
              title: 'Purchase Payment Detail',
              useTheme: true,
            ),
      body: HomeTabLayout(
        title: payment['payment_no']?.toString() ?? '-',
        translateTitle: false,
        subtitle: 'Purchase Payment Detail',
        leading: desktop
            ? IconButton.outlined(
                tooltip: 'Back'.tr,
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, size: 20),
              )
            : null,
        action: desktop ? _actions(context, ctr) : null,
        child: Obx(() {
          final current = _current(ctr);
          final purchase = current['purchase'];
          final supplier = current['supplier'];
          final paymentType = current['payment_type'];
          final currency = current['currency'];
          final error = ctr.formError.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              HomeSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          current['payment_no']?.toString() ?? '-',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _statusChip(context, current['status']?.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paymentAmountText(current),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          paymentDateText(current['payment_date']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              HomeSectionCard(
                title: 'Payment details',
                child: Column(
                  children: [
                    _info(
                      context,
                      'Invoice'.tr,
                      _value(purchase, 'invoice_no'),
                    ),
                    _info(context, 'Supplier'.tr, _value(supplier, 'name')),
                    _info(
                      context,
                      'Payment Type'.tr,
                      _value(paymentType, 'name'),
                    ),
                    _info(context, 'Currency'.tr, _value(currency, 'name')),
                    _info(
                      context,
                      'Payment No'.tr,
                      current['payment_no']?.toString() ?? '-',
                    ),
                    _info(context, 'Note'.tr, _value(current, 'note')),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: desktop
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _actions(context, ctr),
              ),
            ),
    );
  }

  Widget _actions(BuildContext context, PurchasePaymentController ctr) {
    final theme = Theme.of(context);
    return Obx(() {
      final current = _current(ctr);
      final id = int.tryParse(current['id']?.toString() ?? '');
      final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
      return Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: busy || id == null
                ? null
                : () => ctr.onDeletePurchasePayment(
                    context,
                    id,
                    onDeleted: () => Get.back(),
                  ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(100, 48),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('Delete'.tr),
          ),
          FilledButton.icon(
            onPressed: busy
                ? null
                : () => ctr.editPurchasePayment(context, current),
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
    });
  }
}
