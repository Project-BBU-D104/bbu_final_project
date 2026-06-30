import 'package:frontend/controllers/audit_log_controller.dart';
import 'package:get/get.dart';

class AuditLogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuditLogController>(() => AuditLogController());
  }
}
