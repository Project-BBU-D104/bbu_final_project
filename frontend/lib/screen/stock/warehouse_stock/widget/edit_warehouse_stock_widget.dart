import 'package:flutter/material.dart';
import 'warehouse_stock_form_widget.dart';

class EditWarehouseStockWidget extends StatelessWidget {
  const EditWarehouseStockWidget({super.key, required this.warehouseStockId});
  final int warehouseStockId;
  @override
  Widget build(BuildContext context) =>
      WarehouseStockFormWidget(warehouseStockId: warehouseStockId);
}
