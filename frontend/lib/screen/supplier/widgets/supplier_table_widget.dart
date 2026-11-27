import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class SupplierTableWidget extends StatelessWidget {
  const SupplierTableWidget({super.key, required this.items});
  final List<SupplierModel> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;
    final controller = Get.find<SupplierController>();
    return AppTable<SupplierModel>(
      rows: items,
      onRowTap: (item) => controller.gotoSupplierDetail(item),
      columns: [
        AppTableColumn<SupplierModel>(
          title: 'Supplier',
          flex: 2,
          builder: (context, item) => Row(
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary.withValues(alpha: 0.08),
                  foregroundColor: active,
                  child: item.name.trim().isEmpty
                      ? const Icon(Icons.business_outlined, size: 18)
                      : Text(
                          item.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Tooltip(
                  message: item.name,
                  child: Text(
                    item.name.isEmpty ? '-' : item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppTableColumn<SupplierModel>(
          title: 'Contact details',
          flex: 2,
          builder: (context, item) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTableColumn.value(context, item.email),
              const SizedBox(height: 4),
              AppTableColumn.value(context, item.phone, secondary: true),
            ],
          ),
        ),
        AppTableColumn<SupplierModel>(
          title: 'Status',
          width: 132,
          builder: (context, item) => StatusWidget(
            text: (item.status == true ? 'Active' : 'Inactive').tr,
            status: item.status == true ? 'Active' : 'Inactive',
          ),
        ),
        AppTableColumn<SupplierModel>(
          title: 'Created At',
          width: 160,
          secondary: true,
          builder: (context, item) => AppTableColumn.value(
            context,
            item.createdAt == null
                ? null
                : DateFormatter.formatDate(item.createdAt),
            secondary: true,
          ),
        ),
        AppTableColumn<SupplierModel>(
          title: 'Actions',
          width: 144,
          builder: (context, item) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'View details'.tr,
                onPressed: () => controller.gotoSupplierDetail(item),
                icon: const Icon(Icons.chevron_right, size: 20),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions'.tr,
                icon: const Icon(Icons.more_horiz, size: 20),
                onSelected: (action) {
                  switch (action) {
                    case 'call':
                      callPhone(item.phone);
                    case 'email':
                      openEmail(item.email!);
                    case 'map':
                      openGoogleMap(item.map!);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'call',
                    enabled: item.phone.trim().isNotEmpty,
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18),
                        const SizedBox(width: 12),
                        Text('Call supplier'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'email',
                    enabled: (item.email ?? '').trim().isNotEmpty,
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18),
                        const SizedBox(width: 12),
                        Text('Email supplier'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'map',
                    enabled: usableMapValue(item.map) != null,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 12),
                        Text('Open location'.tr),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
