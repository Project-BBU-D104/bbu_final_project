import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/audit_log_service.dart';
import 'package:get/get.dart';

class AuditLogController extends GetxController {
  AuditLogController({AuditLogService? auditLogService})
    : auditLogService = auditLogService ?? AuditLogService();

  final AuditLogService auditLogService;
  final search = SearchController();
  final actionFilter = ''.obs;
  final isLoading = false.obs;
  final loadFailed = false.obs;
  final auditLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAuditLogs();
  }

  Future<void> getAuditLogs() async {
    if (isLoading.value) return;
    isLoading.value = true;
    loadFailed.value = false;
    try {
      final response = await auditLogService.getAuditLogs();
      if (response is! List) throw const FormatException('Expected audit logs');

      // Preserve the source order of events with equal or absent timestamps.
      final entries = List<Map<String, dynamic>>.from(response).indexed.map((
        entry,
      ) {
        final (index, log) = entry;
        return (index: index, log: log, time: _eventTime(log['created_at']));
      }).toList();
      entries.sort((a, b) {
        final aTime = a.time;
        final bTime = b.time;
        if (aTime == null) {
          return bTime == null ? a.index.compareTo(b.index) : 1;
        }
        if (bTime == null) return -1;
        final byTime = bTime.compareTo(aTime);
        return byTime == 0 ? a.index.compareTo(b.index) : byTime;
      });
      if (!isClosed) auditLogs.assignAll(entries.map((entry) => entry.log));
    } catch (_) {
      if (!isClosed) loadFailed.value = true;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  // The audit model stores timestamps without an offset in UTC.
  DateTime? _eventTime(Object? value) {
    final timestamp = value?.toString().trim() ?? '';
    return DateTime.tryParse('${timestamp}Z') ?? DateTime.tryParse(timestamp);
  }

  void gotoAuditLogDetail(Map<String, dynamic> auditLog) {
    Get.toNamed(AppRoutes.auditLogDetail, arguments: auditLog);
  }
}
