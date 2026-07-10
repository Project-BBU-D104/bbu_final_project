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

  /// CREATE Audit Log
  Future<dynamic> createAuditLog(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      endpoint,
      data,
    );
  }

  /// UPDATE Audit Log
  Future<dynamic> updateAuditLog(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      endpoint,
      id.toString(),
      data,
    );
  }

  /// DELETE Audit Log
  Future<dynamic> deleteAuditLog(int id) async {
    return await _api.delete(
      endpoint,
      id.toString(),
    );
  }
}