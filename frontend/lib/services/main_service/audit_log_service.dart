import 'package:frontend/services/api_service.dart';

class AuditLogService {
  final ApiService _api = ApiService();

  static const String endpoint = "audit_logs";

  /// GET ALL Audit Log
  Future<dynamic> getAuditLogs() async {
    return await _api.get(endpoint);
  }

  /// GET Audit Log BY ID
  Future<dynamic> getAuditLogById(int id) async {
    return await _api.getById(
      endpoint,
      id.toString(),
    );
  }
}