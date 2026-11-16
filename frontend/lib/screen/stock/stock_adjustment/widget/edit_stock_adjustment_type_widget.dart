import 'package:flutter/material.dart';
import 'stock_adjustment_form_widget.dart';

class EditStockAdjustmentTypeWidget extends StatelessWidget {
  const EditStockAdjustmentTypeWidget({
    super.key,
    required this.stockAdjustmentId,
  });
  final int stockAdjustmentId;
  @override
  Widget build(BuildContext context) =>
      StockAdjustmentFormWidget(stockAdjustmentId: stockAdjustmentId);
}
