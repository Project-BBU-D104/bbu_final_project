import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:get/get.dart';
import 'warehouse_card_widget.dart';

class WarehouseTableWidget extends StatelessWidget {
  const WarehouseTableWidget({super.key, required this.warehouses});
  final List<Map<String, dynamic>> warehouses;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WarehouseController>();
    return AppTable<Map<String, dynamic>>(
      rows: warehouses,
      onRowTap: c.gotoWarehouseDetail,
      columns: [
        AppTableColumn(
          title: 'Warehouse Name',
          flex: 2,
          builder: (context, row) => TextButton(
            onPressed: () => c.gotoWarehouseDetail(row),
            child: Tooltip(
              message: warehouseValue(row['name']),
              child: Text(
                warehouseValue(row['name']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        AppTableColumn(
          title: 'Reference No',
          builder: (context, row) => AppTableColumn.value(
            context,
            warehouseValue(row['reference_no']),
          ),
        ),
        AppTableColumn(
          title: 'Location',
          flex: 2,
          builder: (context, row) =>
              AppTableColumn.value(context, warehouseValue(row['location'])),
        ),
        AppTableColumn(
          title: 'Actions',
          builder: (context, row) => WarehouseRowActions(warehouse: row),
        ),
      ],
    );
  }
}
