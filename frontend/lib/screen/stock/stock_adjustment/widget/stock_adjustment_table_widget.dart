import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:get/get.dart';
import 'stock_adjustment_card_widget.dart';

class StockAdjustmentTableWidget extends StatelessWidget {
  const StockAdjustmentTableWidget({super.key, required this.stockAdjustments});
  final List<Map<String, dynamic>> stockAdjustments;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockAdjustmentController>();
    return AppTable<Map<String, dynamic>>(
      rows: stockAdjustments,
      onRowTap: c.gotoStockAdjustmentDetailScreen,
      columns: [
        AppTableColumn(
          title: 'Reference NO',
          builder: (context, data) => TextButton(
            onPressed: () => c.gotoStockAdjustmentDetailScreen(data),
            child: Text(
              adjustmentValue(data['reference_no']),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        AppTableColumn(
          title: 'Product',
          builder: (context, data) => AppTableColumn.value(
            context,
            adjustmentRelation(data, 'product'),
          ),
        ),
        AppTableColumn(
          title: 'Warehouse',
          builder: (context, data) => AppTableColumn.value(
            context,
            adjustmentRelation(data, 'warehouse'),
          ),
        ),
        AppTableColumn(
          title: 'Stock Change',
          builder: (context, data) =>
              AppTableColumn.value(context, adjustmentChange(data)),
        ),
        AppTableColumn(
          title: 'Previous Stock',
          builder: (context, data) =>
              Text(adjustmentValue(data['previous_qty'])),
        ),
        AppTableColumn(
          title: 'New Quantity',
          builder: (context, data) => Text(adjustmentValue(data['new_qty'])),
        ),
        AppTableColumn(
          title: 'Actions',
          builder: (context, data) =>
              StockAdjustmentActions(id: int.tryParse('${data['id']}')),
        ),
      ],
    );
  }
}
