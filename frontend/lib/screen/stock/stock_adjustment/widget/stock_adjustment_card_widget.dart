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
          Text(
            adjustmentValue(data['reference_no']),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(adjustmentRelation(data, 'product')),
          Text('${'Warehouse'.tr}: ${adjustmentRelation(data, 'warehouse')}'),
          const SizedBox(height: AppSpacing.md),
          Text(adjustmentChange(data)),
          Text(
            '${'Previous Stock'.tr}: ${adjustmentValue(data['previous_qty'])} → ${'New Quantity'.tr}: ${adjustmentValue(data['new_qty'])}',
          ),
          Obx(
            () => Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                TextButton(
                  onPressed: c.isSaving.value || c.isOpeningEdit.value
                      ? null
                      : () => c.editStockAdjustment(context, data['id']),
                  child: Text('Edit'.tr),
                ),
                TextButton(
                  onPressed: c.isSaving.value
                      ? null
                      : () => c.onDeleteStockAdjustment(data['id'], context),
                  child: Text('Delete'.tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
