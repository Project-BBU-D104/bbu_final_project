class AuditLogsModel {
  final int? id;
  final int userId;
  final int recordId;
  final String action;
  final String? tableName;
  final String title;
  final String oldValue;
  final String newValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuditLogsModel({
    this.id,
    required this.userId,
    required this.recordId,
    required this.title,
    required this.action,
    required this.oldValue,
    required this.newValue,
    this.tableName,
    this.createdAt,
    this.updatedAt,
  });

  factory AuditLogsModel.fromJson(Map<String, dynamic> json) {
    return AuditLogsModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      recordId: json['record_id'] as int,
      action: json['action'] as String,
      title: json['title'] as String,
      oldValue: json['old_value'] as String,
      newValue: json['new_value'] as String,
      tableName: json['table_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'record_id': recordId,
      'action': action,
      'old_value': oldValue,
      'title': title,
      'new_value': newValue,
      'table_name': tableName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AuditLogsModel copyWith({
    int? id,
    int? userId,
    int? recordId,
    String? action,
    String? title,
    String? oldValue,
    String? newValue,
    String? tableName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuditLogsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      title: title ?? this.title,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      tableName: tableName ?? this.tableName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AuditLogsModel(id: $id, title : $title, new_value: $newValue,old_value: $oldValue,record_id: $recordId, user_id: $userId, table_name: $tableName, action: $action)';
  }
}