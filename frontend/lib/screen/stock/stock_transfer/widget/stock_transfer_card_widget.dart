import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

// Display helpers are feature-local and use one local-time policy everywhere.
String transferDate(Map<String, dynamic> transfer) => DateFormatter.formatDate(
  DateTime.tryParse(transfer['transfer_date']?.toString() ?? '')?.toLocal(),
);
List<Map<String, dynamic>> transferRows(Map<String, dynamic> transfer) =>
    (transfer['product_transfer_items'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
int transferTotal(Map<String, dynamic> transfer) =>
    transferRows(transfer).fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item['qty']?.toString() ?? '') ?? 0),
    );
String transferWarehouse(Map<String, dynamic> transfer, String key) =>
    transfer[key] is Map ? transfer[key]['name']?.toString() ?? '-' : '-';

class StockTransferCardWidget extends StatelessWidget {
  const StockTransferCardWidget({super.key, required this.stockTransfer});
  final Map<String, dynamic> stockTransfer;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProductTransferController>();
    return AppListCard(
      onTap: () => c.gotoStockTransferDetail(stockTransfer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            stockTransfer['reference_no']?.toString() ?? '-',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${'From warehouse'.tr}: ${transferWarehouse(stockTransfer, 'from_warehouse')}',
          ),
          Text(
            '${'To warehouse'.tr}: ${transferWarehouse(stockTransfer, 'to_warehouse')}',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${'Product lines'.tr}: ${transferRows(stockTransfer).length} · ${'Total quantity'.tr}: ${transferTotal(stockTransfer)}',
          ),
          Text('${'Transfer date'.tr}: ${transferDate(stockTransfer)}'),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              TextButton.icon(
                onPressed: () => c.editStockTransfer(context, stockTransfer),
                icon: const Icon(Icons.edit_outlined),
                label: Text('Edit'.tr),
              ),
              TextButton.icon(
                onPressed: () =>
                    c.onDeleteStockTransfer(context, stockTransfer['id']),
                icon: const Icon(Icons.delete_outline),
                label: Text('Delete'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
