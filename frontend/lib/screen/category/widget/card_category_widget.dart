import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class CategoryCardWidget extends StatelessWidget {
  const CategoryCardWidget({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = Get.find<CategoryController>();
    final categoryId = item['id'] is int ? item['id'] as int : null;
    final name = (item['name'] ?? '').toString().trim();
    final description = (item['description'] ?? '').toString().trim();
    final createdAt = DateTime.tryParse(
      (item['created_at'] ?? '').toString(),
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
        onTap: categoryId == null
            ? null
            : () => controller.onEditCategory(categoryId, context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.category_outlined, color: colors.primary),
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
                      if (categoryId == null) return;
                      if (value == 'edit') {
                        controller.onEditCategory(categoryId, context);
                      } else if (value == 'delete') {
                        controller.onDeleteCategory(categoryId, context);
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
              Text(
                description.isEmpty ? '-' : description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  Text(
                    createdAt == null
                        ? '-'
                        : DateFormatter.formatDate(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}