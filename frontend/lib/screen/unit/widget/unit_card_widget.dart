import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UnitCardWidget extends StatelessWidget {
  final Map<String, dynamic> units;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  UnitCardWidget({
    super.key,
    required this.units,
    this.onEdit,
    this.onDelete,
  });

  final ctr = Get.put(UnitController());

  String formatDate(dynamic date) {
    if(date == null) return "-";
    try {
      return DateFormat("dd MMM yyyy, hh:mm a")
          .format(DateTime.parse(date.toString()));
    } catch(e){
      return "-";
    }
  }
  @override
  Widget build(BuildContext context) {
    final bool isActive = units['status'] ?? false;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                /// Unit Icon
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                /// Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            units['name'] ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        units['description'] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                /// Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive
                        ? "Active"
                        : "Inactive",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  onSelected: (value){
                    if(value == "edit"){
                      ctr.editUnit(context, units['id']);
                    }
                    if(value == "delete"){
                      ctr.onDeleteUnit(context, units['id']);
                    }
                  },
                  itemBuilder: (context)=>[
                    const PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  ],
                )
              ]
            ),
            const SizedBox(height: 16),
            const Divider(),
            /// Date Info
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today,
                    title: "Created",
                    value: formatDate(
                      units['created_at'],
                    ),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.update,
                    title: "Updated",
                    value: formatDate(
                      units['updated_at'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}