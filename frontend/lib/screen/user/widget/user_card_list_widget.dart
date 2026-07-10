import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserCardListWidget extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserCardListWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<UserController>().gotoUserDetail(user);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user["name"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(user["email"] ?? ""),

                    const SizedBox(height: 4),

                    Text(
                      user["created_at"] != null
                          ? DateFormat("dd MMM yyyy").format(
                              DateTime.parse(user["created_at"]),
                            )
                          : "",
                    ),
                  ],
                ),
              ),

              const StatusWidget(text: "Active"),
            ],
          ),
        ),
      ),
    );
  }
}