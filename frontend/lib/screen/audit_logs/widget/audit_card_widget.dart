import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:get/get.dart';

class AuditCardWidget extends StatelessWidget {
  final Map<String, dynamic> auditLog;

  const AuditCardWidget({
    super.key,
    required this.auditLog,
  });

  ({IconData icon, Color color, Color bg}) get _actionStyle {
    final action = (auditLog["action"] ?? "").toString().toUpperCase();

    switch (action) {
      case "CREATE":
        return (
          icon: Icons.add_circle_outline,
          color: const Color(0xFF059669),
          bg: const Color(0xFFD1FAE5),
        );

      case "UPDATE":
        return (
          icon: Icons.edit_outlined,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFDBEAFE),
        );

      case "DELETE":
        return (
          icon: Icons.delete_outline,
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFEE2E2),
        );

      case "LOGIN":
        return (
          icon: Icons.login,
          color: const Color(0xFF7C3AED),
          bg: const Color(0xFFEDE9FE),
        );

      case "LOGOUT":
        return (
          icon: Icons.logout,
          color: const Color(0xFF6B7280),
          bg: const Color(0xFFF3F4F6),
        );

      default:
        return (
          icon: Icons.info_outline,
          color: const Color(0xFF6B7280),
          bg: const Color(0xFFF3F4F6),
        );
    }
  }

  Map<String, dynamic>? _tryDecode(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
    }

    return null;
  }

  MapEntry<String, List<dynamic>>? _singleFieldDiff() {
    final oldMap = _tryDecode(auditLog["old_value"]);
    final newMap = _tryDecode(auditLog["new_value"]);

    if (oldMap == null || newMap == null) return null;

    final changed = <String, List<dynamic>>{};

    for (final key in newMap.keys) {
      if (oldMap.containsKey(key) && oldMap[key] != newMap[key]) {
        changed[key] = [oldMap[key], newMap[key]];
      }
    }

    if (changed.length == 1) {
      return changed.entries.first;
    }

    return null;
  }

  String _buildFallbackDescription() {
    final action = (auditLog["action"] ?? "").toString().toUpperCase();

    final oldMap = _tryDecode(auditLog["old_value"]);
    final newMap = _tryDecode(auditLog["new_value"]);

    final table = auditLog["table_name"] ?? "";
    final id = auditLog["record_id"] ?? "";

    if (action == "CREATE" && newMap != null) {
      final fields =
          newMap.entries.map((e) => "${e.key}: ${e.value}").join(", ");

      return "Created $table record #$id ($fields)";
    }

    if (action == "DELETE" && oldMap != null) {
      final fields =
          oldMap.entries.map((e) => "${e.key}: ${e.value}").join(", ");

      return "Deleted $table record #$id ($fields)";
    }

    if (action == "UPDATE" && oldMap != null && newMap != null) {
      final changes = <String>[];

      for (final key in newMap.keys) {
        if (oldMap.containsKey(key) && oldMap[key] != newMap[key]) {
          changes.add("$key from ${oldMap[key]} to ${newMap[key]}");
        }
      }

      if (changes.isNotEmpty) {
        return "Updated ${changes.join(", ")}";
      }
    }

    return "${auditLog["title"]} on $table #$id";
  }

  @override
  Widget build(BuildContext context) {
    final style = _actionStyle;
    final diff = _singleFieldDiff();

    return GestureDetector(
      onTap: () {
        Get.find<AuditLogController>().gotoAuditLogDetail(auditLog);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: style.color,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    auditLog["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auditLog["action"] ?? "",
                    style: TextStyle(
                      color: style.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: diff != null
                  ? RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xff374151),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Updated ${diff.key} from ",
                          ),
                          TextSpan(
                            text: "${diff.value[0]}",
                            style: const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const TextSpan(text: " to "),
                          TextSpan(
                            text: "${diff.value[1]}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      _buildFallbackDescription(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff374151),
                      ),
                    ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                const Icon(
                  Icons.person_outline,
                  size: 15,
                  color: Colors.grey,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    auditLog["user"]?["name"] ?? "",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [

                const Icon(
                  Icons.access_time,
                  size: 15,
                  color: Colors.grey,
                ),

                const SizedBox(width: 4),

                Text(
                  (auditLog["created_at"] ?? "").toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
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