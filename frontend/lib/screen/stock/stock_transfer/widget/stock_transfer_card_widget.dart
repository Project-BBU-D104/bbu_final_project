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
    final id = stockTransfer['id'];
    final errorColor = Theme.of(context).colorScheme.error;
    return AppListCard(
      onTap: () => c.gotoStockTransferDetail(stockTransfer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stockTransfer['reference_no']?.toString() ?? '-',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Obx(
                () => PopupMenuButton<String>(
                  tooltip: 'Actions'.tr,
                  enabled: !c.isSaving.value &&
                      !c.isOpeningEdit.value &&
                      id is int,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    if (id is! int) return;
                    if (action == 'edit') {
                      c.editStockTransfer(context, stockTransfer);
                    } else if (action == 'delete') {
                      c.onDeleteStockTransfer(context, id);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: errorColor),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Delete'.tr, style: TextStyle(color: errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}
