import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = Get.find<CustomerController>();
    final customerId = item['id'] is int ? item['id'] as int : null;
    final name = (item['name'] ?? '').toString().trim();
    final phone = (item['phone'] ?? '').toString().trim();
    final address = (item['address'] ?? '').toString().trim();
    final photo = (item['photo'] ?? '').toString().trim();
    final active = item['is_active'] == true;
    final createdAt = DateTime.tryParse((item['created_at'] ?? '').toString());
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
        onTap: customerId == null
            ? null
            : () => controller.editCustomer(context, customerId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppCachedImage(
                      url: photo.isEmpty ? null : photo,
                      width: 56,
                      height: 56,
                      fallbackIcon: Icons.person_outline,
                    ),
                  ),
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
                      if (customerId == null) return;
                      if (value == 'edit') {
                        controller.editCustomer(context, customerId);
                      } else if (value == 'delete') {
                        controller.onDeleteCustomer(customerId, context);
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
              Text(phone.isEmpty ? '-' : phone),
              const SizedBox(height: 8),
              Text(
                address.isEmpty ? '-' : address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  dateGroup(Icons.access_time_rounded, 'Created', createdAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}