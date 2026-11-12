import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserCardListWidget extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserCardListWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final createdAt = DateTime.tryParse(user["created_at"]?.toString() ?? "");
    return GestureDetector(
      onTap: () {
        Get.find<UserController>().gotoUserDetail(user);
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    user["photo"] != null && user["photo"].toString().isNotEmpty
                    ? NetworkImage(user["photo"])
                    : const AssetImage("assets/images/default_avatar.png"),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user["name"]?.toString() ?? "-",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(user["email"]?.toString() ?? "-"),

                    const SizedBox(height: 4),

                    Text(
                      createdAt == null
                          ? "-"
                          : DateFormat("dd MMM yyyy").format(createdAt),
                    ),
                  ],
                ),
              ),

              StatusWidget(
                text: (user["is_active"] == true ? "Active" : "Inactive").tr,
                color: user["is_active"] == true ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
