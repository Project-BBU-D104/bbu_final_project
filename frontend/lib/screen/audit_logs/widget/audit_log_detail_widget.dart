import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class AuditLogDetailWidget extends StatelessWidget {
  AuditLogDetailWidget({super.key});

  final ctr = Get.find<AuditLogController>();

  final Map<String, dynamic> auditLog =
      Map<String, dynamic>.from(Get.arguments);

  Color getActionColor(String action) {
    switch (action.toUpperCase()) {
      case "CREATE":
        return Colors.green;
      case "UPDATE":
        return Colors.orange;
      case "DELETE":
        return Colors.red;
      case "LOGIN":
        return Colors.blue;
      case "LOGOUT":
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case "CREATE":
        return Icons.add_circle_outline;
      case "UPDATE":
        return Icons.edit_outlined;
      case "DELETE":
        return Icons.delete_outline;
      case "LOGIN":
        return Icons.login;
      case "LOGOUT":
        return Icons.logout;
      default:
        return Icons.history;
    }
  }

  Map<String, dynamic> _decode(dynamic value) {
    if (value == null) return {};

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final data = jsonDecode(value);
        if (data is Map<String, dynamic>) {
          return data;
        }
      } catch (_) {}
    }

    return {};
  }

  Widget _buildMap(Map<String, dynamic> map, Color color) {
    if (map.isEmpty) {
      return const Text(
        "No data",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: map.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "${e.value}",
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _card(String title, dynamic value, Color color) {
    final map = _decode(value);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildMap(map, color),
        ],
      ),
    );
  }

  Widget _deleteCard() {
    final oldMap = _decode(auditLog["old_value"]);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: .2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Deleted Data",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildMap(oldMap, Colors.red),
        ],
      ),
    );
  }

  Widget _infoTile(
      IconData icon,
      String title,
      String value,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = (auditLog["action"] ?? "").toString();

    final color = getActionColor(action);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(title: "Audit Detail"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: .7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      getActionIcon(action),
                      size: 34,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    auditLog["title"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    action,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _infoTile(
                      Icons.person,
                      "User",
                      auditLog["user"]?["name"] ?? "",
                    ),

                    _infoTile(
                      Icons.table_chart,
                      "Table",
                      auditLog["table_name"]?.toString() ?? "",
                    ),

                    _infoTile(
                      Icons.tag,
                      "Record ID",
                      auditLog["record_id"]?.toString() ?? "",
                    ),

                    _infoTile(
                      Icons.schedule,
                      "Created At",
                      auditLog["created_at"]?.toString() ?? "",
                    ),
                  ],
                ),
              ),
            ),

            if (action.toUpperCase() == "DELETE")
              _deleteCard()
            else ...[
              _card(
                "Old Value",
                auditLog["old_value"],
                Colors.red,
              ),
              _card(
                "New Value",
                auditLog["new_value"],
                Colors.green,
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctr.onDeleteAuditLog();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text("Delete".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ctr.onEditAuditLog(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: Text("Edit".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}