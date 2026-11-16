import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

String warehouseValue(dynamic value) =>
    value == null || value.toString().trim().isEmpty
    ? 'Not available'.tr
    : value.toString();

class WarehouseCardWidget extends StatelessWidget {
  const WarehouseCardWidget({super.key, required this.warehouse});
  final Map<String, dynamic> warehouse;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WarehouseController>();
    return AppListCard(
      onTap: () => c.gotoWarehouseDetail(warehouse),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            warehouseValue(warehouse['name']),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${'Reference No'.tr}: ${warehouseValue(warehouse['reference_no'])}',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${'Location'.tr}: ${warehouseValue(warehouse['location'])}'),
          const SizedBox(height: AppSpacing.md),
          WarehouseRowActions(warehouse: warehouse),
        ],
      ),
    );
  }
}

class WarehouseRowActions extends StatelessWidget {
  const WarehouseRowActions({super.key, required this.warehouse});
  final Map<String, dynamic> warehouse;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WarehouseController>();
    return Obx(() {
      final busy = c.isSaving.value || c.isOpeningEdit.value;
      final id = warehouse['id'];
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          IconButton(
            tooltip: 'Edit'.tr,
            onPressed: busy || id is! int
                ? null
                : () => c.editWarehouse(context, id),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete'.tr,
            onPressed: busy || id is! int
                ? null
                : () => c.deleteWarehouse(context, id),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      );
    });
  }
}
