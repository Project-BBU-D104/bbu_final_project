import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class UserTableListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const UserTableListWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;
    final controller = Get.find<UserController>();

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
                    label: heading('User'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Contact details'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Role'),
                    columnWidth: const FixedColumnWidth(140),
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
                  for (final user in users)
                    _buildRow(context, user, controller, colors, active, value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    Map<String, dynamic> user,
    UserController controller,
    ColorScheme colors,
    Color activeColor,
    Widget Function(String? text, {bool secondary}) value,
  ) {
    final role = user['role'] is Map
        ? Map<String, dynamic>.from(user['role'] as Map)
        : <String, dynamic>{};
    final photo = user['photo']?.toString() ?? '';
    final userId = int.tryParse(user['id']?.toString() ?? '');
    final isActive = user['is_active'] == true;
    final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '');
    void openDetails() => controller.gotoUserDetail(user);

    return DataRow(
      onSelectChanged: (_) => openDetails(),
      cells: [
        DataCell(
          Row(
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: photo.isNotEmpty
                      ? NetworkImage(photo)
                      : const AssetImage('assets/images/default_avatar.png'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Tooltip(
                  message: user['name']?.toString() ?? '-',
                  child: Text(
                    user['name']?.toString() ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              value(user['email']?.toString()),
              const SizedBox(height: 4),
              value(user['phone']?.toString(), secondary: true),
            ],
          ),
        ),
        DataCell(value(role['name']?.toString())),
        DataCell(
          StatusWidget(
            text: (isActive ? 'Active' : 'Inactive').tr,
            color: isActive ? activeColor : colors.onSurface,
          ),
        ),
        DataCell(value(DateFormatter.formatDate(createdAt), secondary: true)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'View details'.tr,
                onPressed: openDetails,
                icon: const Icon(Icons.chevron_right, size: 20),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions'.tr,
                icon: const Icon(Icons.more_horiz, size: 20),
                onSelected: (action) {
                  if (userId == null) return;
                  if (action == 'edit') {
                    controller.editUser(context, userId);
                  } else if (action == 'delete') {
                    controller.deleteUser(userId, context);
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
            ],
          ),
        ),
      ],
    );
  }
}
