import 'package:flutter/material.dart';
import 'package:frontend/models/audit_logs_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/audit_logs/widget/add_audit_log_widget.dart';
import 'package:frontend/screen/audit_logs/widget/edit_audit_log_widget.dart';
import 'package:frontend/services/main_service/audit_log_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class AuditLogController extends GetxController{

  var isLoading = false.obs;
  final AuditLogService auditLogService = AuditLogService();

  final auditLogs = <Map<String, dynamic>> [].obs;

  @override
  void onInit() {
    super.onInit();
    getAuditLogs();
  }

  Future<void> getAuditLogs() async {
    try{
      isLoading.value = true;

      final resp = await auditLogService.getAuditLogs();

      if(resp is List){
        auditLogs.value = List<Map<String, dynamic>>.from(resp);
      }

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }finally{
      isLoading.value = false;
    }
  }

  void addAuditLog(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddAuditLogWidget()
    );
  }

  void gotoAuditLogDetail(Map<String, dynamic> auditLog) {
    Get.toNamed(
      AppRoutes.auditLogDetail,
      arguments: auditLog,
    );
  }

  void onEditAuditLog(BuildContext context) {
    AppBottomSheets.show(
      context,
      child: EditAuditLogWidget()
    );
  }

  void onDeleteAuditLog(){
    print("Delete audit log");
  }
}