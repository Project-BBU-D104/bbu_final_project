class RoleModel {
  final int? id;
  final String name;
  final String description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleModel({
    this.id,
    required this.name,
    required this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool?,
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
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RoleModel copyWith({
    int? id,
    String? name,
    String? description,
    String? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive:  this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoleModel(id: $id, name: $name, is_active: $isActive, description: $description)';
  }
}