import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CardCategoryWidget extends StatelessWidget {
  final Map<String, dynamic> category;

  CardCategoryWidget({
    super.key,
    required this.category,
  });

  final ctr = Get.find<CategoryController>();

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return "-";

    try {
      final date = DateTime.parse(value).toLocal();
      return DateFormat("dd MMM yyyy • hh:mm a").format(date);
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: titleColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Category Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.category_rounded,
              color: primaryColor,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          /// Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category["name"]?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  category["description"]?.toString() ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Created: ${formatDate(category["created_at"]?.toString())}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case "edit":
                  ctr.onEditCategory(category["id"], context);
                  break;

                case "delete":
                  ctr.onDeleteCategory(category["id"]);
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
    );
  }
}