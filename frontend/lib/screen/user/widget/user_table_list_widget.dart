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
    final controller = Get.find<UserController>();

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
              dataRowMaxHeight: 72,
              horizontalMargin: 16,
              columnSpacing: 24,
              dividerThickness: 0.7,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              columns: const [
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((user) {
                final role = user['role'] is Map
                    ? Map<String, dynamic>.from(user['role'] as Map)
                    : <String, dynamic>{};
                final photo = user['photo']?.toString() ?? '';
                final userId = int.tryParse(user['id']?.toString() ?? '');
                final openDetails = () => controller.gotoUserDetail(user);
                final createdAt = DateTime.tryParse(
                  user['created_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 190,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: photo.isNotEmpty
                                  ? NetworkImage(photo)
                                  : const AssetImage(
                                      'assets/images/default_avatar.png',
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                user['name']?.toString() ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          user['email']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(user['phone']?.toString() ?? '-'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(role['name']?.toString() ?? '-'),
                      onTap: openDetails,
                    ),
                    DataCell(
                      StatusWidget(
                        text: user['is_active'] == true ? 'Active' : 'Inactive',
                        color: user['is_active'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      onTap: openDetails,
                    ),
                    DataCell(
                      Text(DateFormatter.formatDate(createdAt)),
                      onTap: openDetails,
                    ),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Actions'.tr,
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
