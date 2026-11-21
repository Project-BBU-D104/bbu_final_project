import 'package:get/get.dart';

/// Read-only presentation of the audit payload used by both routes.
class AuditEvent {
  const AuditEvent(this.data);

  final Map<String, dynamic> data;

  String get title => _text(data['title']);
  String get displayTitle => title.isEmpty ? 'Audit event'.tr : title;
  String get action => _text(data['action']).toUpperCase();
  String get actor {
    final user = data['user'];
    return user is Map ? _text(user['name']) : '';
  }

  String get table => _text(data['table_name']);
  String get recordId => _text(data['record_id']);
  String get timestamp => _text(data['created_at']);
  String get displayTimestamp => timestamp.replaceFirst('T', ' ');
  String get record => [
    table,
    if (recordId.isNotEmpty) '#$recordId',
  ].where((part) => part.isNotEmpty).join(' ');

  bool matches(List<String> terms) {
    if (terms.isEmpty) return true;
    final searchable = [
      title,
      actor,
      record,
      action,
      actionLabel(action),
      timestamp,
      displayTimestamp,
      _text(data['id']),
    ].join(' ').toLowerCase();
    return terms.every(searchable.contains);
  }

  static String actionLabel(String action) => switch (action) {
    'CREATE' => 'Created'.tr,
    'UPDATE' => 'Updated'.tr,
    'DELETE' => 'Deleted'.tr,
    'LOGIN' => 'Signed in'.tr,
    'LOGOUT' => 'Signed out'.tr,
    '' => 'Unknown action'.tr,
    _ => action,
  };

  static String _text(Object? value) => value?.toString().trim() ?? '';
}
