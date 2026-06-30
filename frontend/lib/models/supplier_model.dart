class SupplierModel {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? map;
  final String? address;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierModel({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.map,
    this.address,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      map: json['map'] as String?,
      address: (json['address'] as String?),
      status: (json['status'] as String?) ?? 'Active',
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
      'phone': phone,
      'email': email,
      'map': map,
      'address': address,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? map,
    String? address,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      map: map ?? this.map,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SupplierModel(id: $id, name: $name, email: $email, map: $map, phone: $phone, address: $address, status: $status)';
  }
}