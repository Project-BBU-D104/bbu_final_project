import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class RoleCardWidget extends StatelessWidget {
  final Map<String, dynamic> role;
  RoleCardWidget({super.key, required this.role});

  final ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final roleId = int.tryParse(role["id"]?.toString() ?? "");
    final createdAt = DateTime.tryParse(role["created_at"]?.toString() ?? "");
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  role["name"]?.toString() ?? "-",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                StatusWidget(
                  text: (role["is_active"] == true ? "Active" : "Inactive").tr,
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Description
            Text(
              role["description"]?.toString() ?? "-",
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 15,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  createdAt == null ? "-" : DateFormatter.formatDate(createdAt),
                ),
                Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case "edit":
                        if (roleId != null) {
                          ctr.editRole(context, roleId);
                        }
                        break;

                      case "delete":
                        if (roleId != null) {
                          ctr.onDeleteRole(roleId, context);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 10),
                          Text("Edit".tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Delete".tr,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
