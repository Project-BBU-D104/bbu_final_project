import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentTypeCardWidget extends StatelessWidget {
  final Map<String, dynamic> paymentType;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  PaymentTypeCardWidget({
    super.key,
    required this.paymentType,
    this.onEdit,
    this.onDelete,
  });

  final ctr = Get.find<PaymentTypeController>();

  String formatDate(dynamic date) {
    if (date == null) return "-";

    try {
      return DateFormat("dd MMM yyyy, hh:mm a")
          .format(DateTime.parse(date.toString()));
    } catch (e) {
      return "-";
    }
  }
  @override
  Widget build(BuildContext context) {
    final bool isActive = paymentType['status'] ?? false;
    return Card(
      elevation: 3,
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
                /// Payment Icon
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    Icons.payment,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),
                /// Name + Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentType['name'] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        paymentType['description'] ?? "",
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
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 15,
                        color: isActive
                            ? Colors.green
                            : Colors.red,
                      ),

                      const SizedBox(width: 4),

                      Text(
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
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                /// Action Menu
                PopupMenuButton<String>(

                  icon: const Icon(
                    Icons.more_vert,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if(value == "edit"){
                      ctr.editPaymentType(
                        context,
                        paymentType['id'],
                      );
                    }
                    if(value == "delete"){
                      ctr.onDeletePaymentType(
                        context,
                        paymentType['id'],
                      );
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
                          Text(
                            "Edit",
                          ),
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

                          Text(
                            "Delete",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            /// Information
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today,
                    title: "Created",
                    value: formatDate(
                      paymentType['created_at'],
                    ),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.update,
                    title: "Updated",
                    value: formatDate(
                      paymentType['updated_at'],
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}