import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class RoleTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> roles;

  const RoleTableWidget({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<RoleController>();

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 76,
                horizontalMargin: 16,
                columnSpacing: 24,
                dividerThickness: 0.7,
                headingRowColor: WidgetStatePropertyAll(
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ),
                columns: [
                  DataColumn(label: Text('Role'.tr)),
                  DataColumn(label: Text('Description'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Created'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: roles.map((role) {
                  final roleId = int.tryParse(role['id']?.toString() ?? '');
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            role['name']?.toString() ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 240,
                          child: Text(
                            role['description']?.toString() ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        StatusWidget(
                          text:
                              (role['is_active'] == true
                                      ? 'Active'
                                      : 'Inactive')
                                  .tr,
                        ),
                      ),
                      DataCell(Text(role['created_at']?.toString() ?? '-')),
                      DataCell(
                        PopupMenuButton<String>(
                          tooltip: 'Actions'.tr,
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
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
