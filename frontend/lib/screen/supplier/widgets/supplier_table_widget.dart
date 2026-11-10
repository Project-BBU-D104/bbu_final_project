import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
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
    final line = colors.onSurface.withValues(alpha: 0.08);
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;
    final controller = Get.find<SupplierController>();
    Widget heading(String label) => Expanded(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    Widget value(String? text, {bool secondary = false}) => Tooltip(
      message: (text ?? '').isEmpty ? '-' : text!,
      child: Text(
        (text ?? '').isEmpty ? '-' : text!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: secondary ? 12 : 14,
          color: secondary ? colors.onSurfaceVariant : colors.onSurface,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Theme(
        data: theme.copyWith(
          dividerColor: line,
          dividerTheme: DividerThemeData(color: line, thickness: 1),
        ),
        child: Card(
          elevation: 0,
          color: theme.cardColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: line),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(960, constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 76,
                columnSpacing: 20,
                horizontalMargin: 24,
                headingRowColor: WidgetStatePropertyAll(
                  Color.alphaBlend(
                    colors.onSurface.withValues(alpha: 0.025),
                    theme.cardColor,
                  ),
                ),
                headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? colors.primary.withValues(alpha: 0.035)
                      : null,
                ),
                columns: [
                  DataColumn(
                    label: heading('Supplier'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Contact details'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Status'),
                    columnWidth: const FixedColumnWidth(132),
                  ),
                  DataColumn(
                    label: heading('Created At'),
                    columnWidth: const FixedColumnWidth(160),
                  ),
                  DataColumn(
                    label: heading('Actions'),
                    columnWidth: const FixedColumnWidth(144),
                  ),
                ],
                rows: [
                  for (final item in items)
                    DataRow(
                      onSelectChanged: (_) =>
                          controller.gotoSupplierDetail(item),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              ExcludeSemantics(
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  foregroundColor: active,
                                  child: item.name.trim().isEmpty
                                      ? const Icon(
                                          Icons.business_outlined,
                                          size: 18,
                                        )
                                      : Text(
                                          item.name.characters.first
                                              .toUpperCase(),
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
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              value(item.email),
                              const SizedBox(height: 4),
                              value(item.phone, secondary: true),
                            ],
                          ),
                        ),
                        DataCell(
                          StatusWidget(
                            text: (item.status == true ? 'Active' : 'Inactive')
                                .tr,
                            color: item.status == true
                                ? active
                                : colors.onSurface,
                          ),
                        ),
                        DataCell(
                          value(
                            item.createdAt == null
                                ? null
                                : DateFormatter.formatDate(item.createdAt),
                            secondary: true,
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'View details'.tr,
                                onPressed: () =>
                                    controller.gotoSupplierDetail(item),
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
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Call supplier'.tr),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'email',
                                    enabled: (item.email ?? '')
                                        .trim()
                                        .isNotEmpty,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 18,
                                        ),
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
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 18,
                                        ),
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
