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
    final theme = Theme.of(context);
    final name = warehouseValue(warehouse['name']);

    Widget detail(IconData icon, String label, dynamic value) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(warehouseValue(value)),
            ],
          ),
        ),
      ],
    );

    return AppListCard(
      onTap: () => c.gotoWarehouseDetail(warehouse),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: name,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              WarehouseRowActions(warehouse: warehouse),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          detail(Icons.tag, 'Reference No', warehouse['reference_no']),
          const SizedBox(height: AppSpacing.md),
          detail(Icons.location_on_outlined, 'Location', warehouse['location']),
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
      final error = Theme.of(context).colorScheme.error;
      return PopupMenuButton<String>(
        tooltip: 'Actions'.tr,
        enabled: !busy && id is int,
        icon: const Icon(Icons.more_vert),
        onSelected: (action) {
          if (id is! int) return;
          if (action == 'edit') {
            c.editWarehouse(context, id);
          } else if (action == 'delete') {
            c.deleteWarehouse(context, id);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined),
                const SizedBox(width: AppSpacing.sm),
                Text('Edit'.tr),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: error),
                const SizedBox(width: AppSpacing.sm),
                Text('Delete'.tr, style: TextStyle(color: error)),
              ],
            ),
          ),
        ],
      );
    });
  }
}
