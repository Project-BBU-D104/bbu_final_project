import 'package:flutter/material.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class AuditLogsScreen extends StatelessWidget {
  AuditLogsScreen({super.key});

  final ctr = Get.find<AuditLogController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Audit Logs"),
      body: Center(child: Text("Audit Logs Screen")),
    );
  }
}