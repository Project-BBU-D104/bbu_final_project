import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

String adjustmentValue(dynamic value) =>
    value == null || '$value'.trim().isEmpty ? '-' : '$value';
String adjustmentRelation(
  Map<String, dynamic> data,
  String name, [
  String field = 'name',
]) => adjustmentValue(data[name] is Map ? data[name][field] : null);
String adjustmentDirection(Map<String, dynamic> data) =>
    data['adjustment_type'] == 'increase'
    ? 'Increase'.tr
    : data['adjustment_type'] == 'decrease'
    ? 'Decrease'.tr
    : '-';
String adjustmentChange(Map<String, dynamic> data) =>
    '${adjustmentDirection(data)} ${data['adjustment_type'] == 'increase'
        ? '+'
        : data['adjustment_type'] == 'decrease'
        ? '-'
        : ''}${adjustmentValue(data['qty'])}';

class StockAdjustmentCardWidget extends StatelessWidget {
  const StockAdjustmentCardWidget({super.key, required this.stockAdjustment});
  final Map<String, dynamic> stockAdjustment;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockAdjustmentController>();
    final data = stockAdjustment;
    return AppListCard(
      onTap: () => c.gotoStockAdjustmentDetailScreen(data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  adjustmentValue(data['reference_no']),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StockAdjustmentActions(id: int.tryParse('${data['id']}')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(adjustmentRelation(data, 'product')),
          Text('${'Warehouse'.tr}: ${adjustmentRelation(data, 'warehouse')}'),
          const SizedBox(height: AppSpacing.md),
          Text(adjustmentChange(data)),
          Text(
            '${'Previous Stock'.tr}: ${adjustmentValue(data['previous_qty'])} → ${'New Quantity'.tr}: ${adjustmentValue(data['new_qty'])}',
          ),
        ],
      ),
    );
  }
}

class StockAdjustmentActions extends StatelessWidget {
  const StockAdjustmentActions({
    super.key,
    required this.id,
    this.closeDetailOnSuccess = false,
  });

  final int? id;
  final bool closeDetailOnSuccess;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StockAdjustmentController>();
    final errorColor = Theme.of(context).colorScheme.error;
    return Obx(
      () => PopupMenuButton<String>(
        tooltip: 'Actions'.tr,
        enabled:
            !controller.isSaving.value &&
            !controller.isOpeningEdit.value &&
            id != null &&
            id! > 0,
        icon: const Icon(Icons.more_vert),
        onSelected: (action) {
          final adjustmentId = id;
          if (adjustmentId == null || adjustmentId <= 0) return;
          if (action == 'edit') {
            controller.editStockAdjustment(context, adjustmentId);
          } else if (action == 'delete') {
            controller.onDeleteStockAdjustment(
              adjustmentId,
              context,
              closeDetailOnSuccess: closeDetailOnSuccess,
            );
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
    );
  }
}
