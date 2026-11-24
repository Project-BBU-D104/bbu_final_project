import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/report_export_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:get/get.dart';

class PaymentSuccessWidget extends StatefulWidget {
  const PaymentSuccessWidget({super.key, this.exportController});
  final ReportExportController? exportController;
  @override
  State<PaymentSuccessWidget> createState() => _PaymentSuccessWidgetState();
}

class _PaymentSuccessWidgetState extends State<PaymentSuccessWidget> {
  late final ReportExportController _exportController =
      widget.exportController ?? ReportExportController();
  final _exporting = false.obs;
  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    final receipt = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final currency = receipt['currency'] is Map
        ? Map<String, dynamic>.from(receipt['currency'])
        : null;
    final date = DateTime.tryParse(receipt['payment_date']?.toString() ?? '');
    final rows = _receiptRows(receipt, currency, date);
    void returnToSale() =>
        Get.offNamedUntil(AppRoutes.sale, ModalRoute.withName(AppRoutes.home));
    return Scaffold(
      appBar: DesktopAppShell.isVisible(context)
          ? null
          : CustomAppBar(
              title: receipt.isEmpty
                  ? 'Receipt unavailable'
                  : 'Payment successful',
              onBack: returnToSale,
            ),
      body: AppPage(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: receipt.isEmpty
                    ? 'Receipt unavailable'
                    : 'Payment successful',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (receipt.isEmpty)
                const AppEmptyState(message: 'Receipt unavailable')
              else
                AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.check_circle_outline),
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row[0].toString()),
                              Text(row[1].toString()),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (receipt.isNotEmpty)
                Obx(
                  () => ElevatedButton(
                    onPressed: _exporting.value
                        ? null
                        : () => _exportReceipt(receipt, currency, date),
                    child: Text(
                      (_exporting.value ? 'Exporting...' : 'Export Receipt').tr,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: returnToSale,
                child: Text('Back to Sale'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportReceipt(
    Map<String, dynamic> receipt,
    Map<String, dynamic>? currency,
    DateTime? paymentDate,
  ) async {
    if (_exporting.value) return;

    _exporting.value = true;
    try {
      final invoice = receipt['invoice_no']?.toString() ?? '';
      final path = await _exportController.exportPdf(
        title: 'Sale Receipt @id'.trParams({'id': invoice}).trim(),
        headers: ['Field'.tr, 'Value'.tr],
        rows: _receiptRows(receipt, currency, paymentDate),
        pageFormat: null,
        summaryTotal: null,
      );

      if (!mounted) return;
      if (path != null) {
        ToastWidget.show(
          message: 'PDF saved to:\n$path',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ToastWidget.show(
        title: 'Export Error'.tr,
        message: error.toString(),
        type: ToastType.error,
      );
    } finally {
      _exporting.value = false;
    }
  }

  List<List<dynamic>> _receiptRows(
    Map<String, dynamic> receipt,
    Map<String, dynamic>? currency,
    DateTime? paymentDate,
  ) {
    return [
      ['Customer'.tr, receipt['customer']?.toString() ?? '—'],
      ['Payment Method'.tr, receipt['payment_method']?.toString() ?? '—'],
      ['Date'.tr, DateFormatter.formatDateTime(paymentDate?.toLocal())],
      ['Invoice'.tr, receipt['invoice_no'] ?? '—'],
      ['Reference No'.tr, receipt['reference_no'] ?? '—'],
      for (final line in receipt['lines'] ?? [])
        [
          line['product_name'],
          "${line['qty']} × ${_formatAmount(line['sale_price'], currency)} = ${_formatAmount(line['subtotal'], currency)}",
        ],
      ['Subtotal'.tr, _formatAmount(receipt['subtotal'], currency)],
      ['Total'.tr, _formatAmount(receipt['total'], currency)],
    ];
  }

  String _formatAmount(Object? value, Map<String, dynamic>? currency) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return CurrencyFormatter.format(amount, currency);
  }
}
