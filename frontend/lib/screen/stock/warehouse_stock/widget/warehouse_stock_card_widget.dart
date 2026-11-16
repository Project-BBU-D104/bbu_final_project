import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/ui/app_list_card.dart';

String stockRelationLabel(Map<String, dynamic> stock, String relation) {
  final value = stock[relation];
  final name = value is Map ? '${value['name'] ?? ''}'.trim() : '';
  if (name.isNotEmpty) return name;
  final id = stock['${relation}_id'] ?? (value is Map ? value['id'] : null);
  return '${(relation == 'warehouse' ? 'Warehouse' : 'Product').tr} ${id ?? 'Unavailable'.tr}';
}

class WarehouseStockActions extends StatelessWidget {
  const WarehouseStockActions({super.key, required this.stock});
  final Map<String, dynamic> stock;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WarehouseStockController>();
    final id = int.tryParse('${stock['id']}');
    return Obx(
      () => PopupMenuButton<String>(
        tooltip: 'Actions'.tr,
        enabled: id != null && !c.isSaving.value && !c.isOpeningEdit.value,
        onSelected: (action) {
          if (action == 'edit') {
            c.editWarehouseStock(context, id!);
          } else {
            c.onDeleteWarehouseStock(id!, context);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text('Edit'.tr)),
          PopupMenuItem(value: 'delete', child: Text('Delete'.tr)),
        ],
      ),
    );
  }
}

class WarehouseStockCardWidget extends StatelessWidget {
  const WarehouseStockCardWidget({super.key, required this.warehouseStock});
  final Map<String, dynamic> warehouseStock;
  @override
  Widget build(BuildContext context) => AppListCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stockRelationLabel(warehouseStock, 'product')),
              Text(stockRelationLabel(warehouseStock, 'warehouse')),
              Text('${'Quantity'.tr}: ${warehouseStock['qty'] ?? 0}'),
            ],
          ),
        ),
        WarehouseStockActions(stock: warehouseStock),
      ],
    ),
  );
}
