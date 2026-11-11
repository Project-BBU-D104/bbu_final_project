import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class UnitCardWidget extends StatelessWidget {
  const UnitCardWidget({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = Get.find<UnitController>();
    final unitId = item['id'] is int ? item['id'] as int : null;
    final name = (item['name'] ?? '').toString().trim();
    final shortName = (item['short_name'] ?? '').toString().trim();
    final description = (item['description'] ?? '').toString().trim();
    final active = item['status'] == true;
    final createdAt = DateTime.tryParse((item['created_at'] ?? '').toString());
    final updatedAt = DateTime.tryParse((item['updated_at'] ?? '').toString());
    Widget chip(
      String text, {
      required Color foreground,
      required Color background,
    }) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    Widget dateGroup(IconData icon, String label, DateTime? date) => Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        Text(
          label.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          date == null ? '-' : DateFormatter.formatDate(date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Card(
      color: theme.cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: unitId == null
            ? null
            : () => controller.onEditUnit(unitId, context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.straighten, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Tooltip(
                      message: name,
                      child: Text(
                        name.isEmpty ? '-' : name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Actions'.tr,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (unitId == null) return;
                      if (value == 'edit') {
                        controller.onEditUnit(unitId, context);
                      } else if (value == 'delete') {
                        controller.onDeleteUnit(unitId, context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 20),
                            const SizedBox(width: 10),
                            Text('Edit'.tr),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: colors.error,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete'.tr,
                              style: TextStyle(color: colors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (shortName.isNotEmpty)
                    chip(
                      shortName,
                      foreground: colors.onSurfaceVariant,
                      background: colors.onSurface.withValues(alpha: 0.06),
                    ),
                  chip(
                    active ? 'Active'.tr : 'Inactive'.tr,
                    foreground: active
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    background: active
                        ? colors.primary.withValues(alpha: 0.08)
                        : colors.onSurface.withValues(alpha: 0.06),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description.isEmpty ? '-' : description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  dateGroup(Icons.access_time_rounded, 'Created', createdAt),
                  dateGroup(Icons.update_rounded, 'Updated', updatedAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
