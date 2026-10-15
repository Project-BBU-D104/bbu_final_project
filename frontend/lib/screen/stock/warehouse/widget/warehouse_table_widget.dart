import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class WarehouseTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> warehouses;

  const WarehouseTableWidget({super.key, required this.warehouses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 72,
              horizontalMargin: 16,
              columnSpacing: 28,
              dividerThickness: 0.7,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              columns: const [
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Note')),
              ],
              rows: warehouses.map((warehouse) {
                final openWarehouse = () => Get.find<WarehouseController>()
                    .gotoWarehouseDetail(warehouse);

                return DataRow(
                  cells: [
                    DataCell(
                      Text((warehouse['reference_no'] ?? '-').toString()),
                      onTap: openWarehouse,
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          (warehouse['name'] ?? '-').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      onTap: openWarehouse,
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          (warehouse['location'] ?? '-').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openWarehouse,
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          (warehouse['note'] ?? '-').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openWarehouse,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
