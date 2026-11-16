import 'package:flutter/material.dart';
import 'package:frontend/ui/app_table.dart';
import 'warehouse_stock_card_widget.dart';

class WarehouseStockTableWidget extends StatelessWidget {
  const WarehouseStockTableWidget({super.key, required this.warehouseStocks});
  final List<Map<String, dynamic>> warehouseStocks;
  @override
  Widget build(BuildContext context) => AppTable<Map<String, dynamic>>(
    rows: warehouseStocks,
    columns: [
      AppTableColumn(
        title: 'Warehouse',
        builder: (context, row) =>
            AppTableColumn.value(context, stockRelationLabel(row, 'warehouse')),
      ),
      AppTableColumn(
        title: 'Product',
        builder: (context, row) =>
            AppTableColumn.value(context, stockRelationLabel(row, 'product')),
      ),
      AppTableColumn(
        title: 'Quantity',
        builder: (context, row) => Text('${row['qty'] ?? 0}'),
      ),
      AppTableColumn(
        title: 'Actions',
        builder: (context, row) => WarehouseStockActions(stock: row),
      ),
    ],
  );
}
