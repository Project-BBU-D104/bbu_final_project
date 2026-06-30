class UserModel {
  final int? id;
  final String username;
  final String password;
  final String? email;
  final String? roleId;
  final String? disable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.roleId,
    this.disable = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String?,
      roleId: json['role_id'] as String?,
      disable: (json['disable'] as String?) ?? 'Active',
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
      'username': username,
      'password': password,
      'email': email,
      'role_id': roleId,
      'disable': disable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? roleId,
    String? disable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      disable: disable ?? this.disable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, role_id: $roleId, password: $password)';
  }
}