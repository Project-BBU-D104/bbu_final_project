class WarehouseModel {
  final int? id;
  final String name;
  final String? location;

  const WarehouseModel({
    this.id,
    required this.name,
    this.location,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  WarehouseModel copyWith({
    int? id,
    String? name,
    String? location,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'WarehouseModel(id: $id, name: $name, location: $location)';
  }
}