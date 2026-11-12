import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class RoleTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> roles;

  const RoleTableWidget({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;
    final controller = Get.find<RoleController>();

    Widget heading(String label) => Expanded(
      child: Tooltip(
        message: label.tr,
        child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );

    Widget value(String? text, {bool secondary = false}) {
      final display = (text ?? '').isEmpty ? '-' : text!;
      return Tooltip(
        message: display,
        child: Text(
          display,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: secondary ? 12 : 14,
            color: secondary ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),
      );
    }

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
                    label: heading('Role'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Description'),
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
                  for (final role in roles)
                    _buildRow(role, controller, context, colors, active, value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
    Map<String, dynamic> role,
    RoleController controller,
    BuildContext context,
    ColorScheme colors,
    Color activeColor,
    Widget Function(String? text, {bool secondary}) value,
  ) {
    final roleId = int.tryParse(role['id']?.toString() ?? '');
    final isActive = role['is_active'] == true;
    final createdAt = DateTime.tryParse(role['created_at']?.toString() ?? '');

    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: role['name']?.toString() ?? '-',
            child: Text(
              role['name']?.toString() ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(value(role['description']?.toString())),
        DataCell(
          StatusWidget(
            text: (isActive ? 'Active' : 'Inactive').tr,
            color: isActive ? activeColor : colors.onSurface,
          ),
        ),
        DataCell(value(DateFormatter.formatDate(createdAt), secondary: true)),
        DataCell(
          PopupMenuButton<String>(
            tooltip: 'Actions'.tr,
            icon: const Icon(Icons.more_horiz, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  if (roleId != null) {
                    controller.editRole(context, roleId);
                  }
                case 'delete':
                  if (roleId != null) {
                    controller.onDeleteRole(roleId, context);
                  }
              }
            },
            itemBuilder: (context) => [
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
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete'.tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
