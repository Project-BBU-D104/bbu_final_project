import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/models/audit_logs_model.dart';
import 'package:get/get.dart';

class AuditCardWidget extends StatelessWidget {
  final AuditLogsModel auditLog;

  const AuditCardWidget({super.key, required this.auditLog});

  // Icon + color per action type
  ({IconData icon, Color color, Color bg}) get _actionStyle {
    switch (auditLog.action.toUpperCase()) {
      case 'CREATE':
        return (
          icon: Icons.add_circle_outline,
          color: const Color(0xFF059669),
          bg: const Color(0xFFD1FAE5),
        );
      case 'UPDATE':
        return (
          icon: Icons.edit_outlined,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFDBEAFE),
        );
      case 'DELETE':
        return (
          icon: Icons.delete_outline,
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFEE2E2),
        );
      case 'LOGIN':
        return (
          icon: Icons.login,
          color: const Color(0xFF7C3AED),
          bg: const Color(0xFFEDE9FE),
        );
      case 'LOGOUT':
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

  Map<String, dynamic>? _tryDecode(String value) {
    if (value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // Returns a single-field diff if exactly one field changed, else null
  MapEntry<String, List<dynamic>>? _singleFieldDiff() {
    final oldMap = _tryDecode(auditLog.oldValue);
    final newMap = _tryDecode(auditLog.newValue);
    if (oldMap == null || newMap == null) return null;

    final changed = <String, List<dynamic>>{};
    for (final key in newMap.keys) {
      if (oldMap.containsKey(key) && oldMap[key] != newMap[key]) {
        changed[key] = [oldMap[key], newMap[key]];
      }
    }
    if (changed.length == 1) return changed.entries.first;
    return null;
  }

  String _buildFallbackDescription() {
    final action = auditLog.action.toUpperCase();
    final oldMap = _tryDecode(auditLog.oldValue);
    final newMap = _tryDecode(auditLog.newValue);

    if (action == 'CREATE' && newMap != null) {
      final fields = newMap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'Created ${auditLog.tableName} record #${auditLog.recordId} ($fields)';
    }
    if (action == 'DELETE' && oldMap != null) {
      final fields = oldMap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'Deleted ${auditLog.tableName} record #${auditLog.recordId} ($fields)';
    }
    if (action == 'UPDATE' && oldMap != null && newMap != null) {
      final changes = <String>[];
      for (final key in newMap.keys) {
        if (oldMap.containsKey(key) && oldMap[key] != newMap[key]) {
          changes.add('$key from ${oldMap[key]} to ${newMap[key]}');
        }
      }
      if (changes.isNotEmpty) return 'Updated ${changes.join(', ')}';
    }
    return '${auditLog.title} on ${auditLog.tableName} #${auditLog.recordId}';
  }

  @override
  Widget build(BuildContext context) {
    final style = _actionStyle;
    final diff = _singleFieldDiff();

    return GestureDetector(
      onTap: () => Get.find<AuditLogController>().gotoAuditLogDetail( auditLog ),
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
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
      
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        auditLog.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          auditLog.action,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: style.color,
                          ),
                        ),
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 8),
      
                  // Description — frosted-glass container with gradient border
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          const Color(0xFFD1D5DB).withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: diff != null
                          ? RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: Color(0xFF374151),
                                ),
                                children: [
                                  TextSpan(text: 'Updated ${diff.key} from '),
                                  TextSpan(
                                    text: '${diff.value[0]}',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const TextSpan(text: ' to '),
                                  TextSpan(
                                    text: '${diff.value[1]}',
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              _buildFallbackDescription(),
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Color(0xFF374151),
                              ),
                            ),
                    ),
                  ),
      
                  const SizedBox(height: 6),
      
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        auditLog.createdAt.toString().substring(0, 16),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}