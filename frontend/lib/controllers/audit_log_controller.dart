import 'package:flutter/material.dart';
import 'package:frontend/models/audit_logs_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/audit_logs/widget/add_audit_log_widget.dart';
import 'package:frontend/screen/audit_logs/widget/edit_audit_log_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class AuditLogController extends GetxController{

  final List<AuditLogsModel> auditLogs = [
    AuditLogsModel(
      id: 1,
      userId: 1,
      recordId: 101,
      action: "CREATE",
      tableName: "products",
      title: 'Create Product',
      oldValue: "",
      newValue: '{"name":"iPhone 15","price":999}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 2,
      userId: 2,
      recordId: 101,
      action: "UPDATE",
      tableName: "products",
      title: 'Update Product',
      oldValue: '{"price":999}',
      newValue: '{"price":1099}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 3,
      userId: 3,
      recordId: 5,
      action: "DELETE",
      title: 'Delete Category',
      tableName: "categories",
      oldValue: '{"name":"Old Category"}',
      newValue: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 4,
      userId: 1,
      recordId: 12,
      action: "UPDATE",
      tableName: "customers",
      title: 'Update Customer',
      oldValue: '{"phone":"012345678"}',
      newValue: '{"phone":"098765432"}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 5,
      userId: 4,
      recordId: 200,
      action: "CREATE",
      title: 'Create Purchase Order',
      tableName: "purchase_orders",
      oldValue: "",
      newValue: '{"supplier":"ABC Supplier","total":350}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 6,
      userId: 2,
      recordId: 350,
      action: "UPDATE",
      tableName: "sales",
      title: 'Update Sale',
      oldValue: '{"status":"Pending"}',
      newValue: '{"status":"Completed"}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 7,
      userId: 5,
      recordId: 8,
      action: "LOGIN",
      title: 'User Login',
      tableName: "users",
      oldValue: "",
      newValue: '{"login":"Success"}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 8,
      userId: 5,
      recordId: 8,
      action: "LOGOUT",
      tableName: "users",
      title: 'User Logout',
      oldValue: '{"status":"Online"}',
      newValue: '{"status":"Offline"}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 9,
      userId: 6,
      recordId: 18,
      action: "UPDATE",
      tableName: "roles",
      title: 'Update Role',
      oldValue: '{"role":"Cashier"}',
      newValue: '{"role":"Manager"}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AuditLogsModel(
      id: 10,
      userId: 1,
      recordId: 99,
      action: "DELETE",
      title: 'Delete Supplier',
      tableName: "suppliers",
      oldValue: '{"name":"XYZ Supplier"}',
      newValue: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  void addAuditLog(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddAuditLogWidget()
    );
  }

  void gotoAuditLogDetail(AuditLogsModel log) {
    Get.toNamed(
      AppRoutes.auditLogDetail,
      arguments: log,
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