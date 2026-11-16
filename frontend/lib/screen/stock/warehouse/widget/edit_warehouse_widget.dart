import 'package:flutter/material.dart';
import 'warehouse_form_widget.dart';

class EditWarehouseWidget extends StatelessWidget {
  const EditWarehouseWidget({super.key, required this.warehouseId});
  final int warehouseId;
  @override
  Widget build(BuildContext context) =>
      WarehouseFormWidget(warehouseId: warehouseId);
}
