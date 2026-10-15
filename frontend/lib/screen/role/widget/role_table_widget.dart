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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
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
              columns: const [
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Actions')),
              ],
              rows: roles.map((role) {
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
                        text: role['is_active'] == true ? 'Active' : 'Inactive',
                      ),
                    ),
                    DataCell(Text(role['created_at']?.toString() ?? '-')),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Actions'.tr,
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              controller.editRole(context, role['id']);
                            case 'delete':
                              controller.onDeleteRole(role['id'], context);
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
    );
  }
}
