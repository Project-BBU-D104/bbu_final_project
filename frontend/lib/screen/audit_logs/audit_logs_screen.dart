import 'package:flutter/material.dart';
import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:frontend/screen/audit_logs/widget/audit_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class AuditLogsScreen extends StatelessWidget {
  AuditLogsScreen({super.key});

  final ctr = Get.find<AuditLogController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Audit Logs"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              SearchWidget(title: "Search Audit Logs"),

              const SizedBox(height: 10),
              Row(children: [
                ChipWidget(title: "All"),
                ChipWidget(title: "Pending"),
                ChipWidget(title: "Completed"),
                ChipWidget(title: "Canceled"),
              ],),

              Obx(()=> ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctr.auditLogs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AuditCardWidget(auditLog: ctr.auditLogs[index],),
                  ),
                ),
              ),
              SizedBox(height: 70)
            ],
          ),
        )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addAuditLog(context);
        }, 
        child: const Icon(Icons.add)
      ),
    );
  }
}