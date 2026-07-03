import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/models/audit_logs_model.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class AuditLogDetailWidget extends StatelessWidget {
  AuditLogDetailWidget({super.key});


  final ctr = Get.find<AuditLogController>();
  final AuditLogsModel log = Get.arguments as AuditLogsModel;

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

  /// SAFE JSON
  Map<String, dynamic> _decode(String value) {
    if (value.trim().isEmpty) return {};
    try {
      final data = jsonDecode(value);
      return data is Map<String, dynamic> ? data : {};
    } catch (_) {
      return {};
    }
  }

  /// FORMAT LIST UI
  Widget _buildMap(Map<String, dynamic> map, Color color) {
    if (map.isEmpty) {
      return const Text("No data",
          style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: map.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  "${e.value}",
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// CARD
  Widget _card(String title, String value, Color color) {
    final map = _decode(value);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMap(map, color),
        ],
      ),
    );
  }

  /// SPECIAL DELETE UI (IMPORTANT)
  Widget _deleteCard() {
    final oldMap = _decode(log.oldValue);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
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
          const SizedBox(height: 10),
          _buildMap(oldMap, Colors.red),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getActionColor(log.action);

    final oldMap = _decode(log.oldValue);
    final newMap = _decode(log.newValue);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(title: "Audit Detail"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(getActionIcon(log.action),
                        color: color, size: 35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    log.title ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.action,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            /// BODY
            if (log.action.toUpperCase() == "DELETE")
              _deleteCard()
            else ...[
              _card("Old Value", log.oldValue, Colors.red),
              _card("New Value", log.newValue, Colors.green),
            ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ctr.onEditAuditLog(context);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text("Edit".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: titleColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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