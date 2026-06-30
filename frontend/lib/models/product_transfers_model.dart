class ProductTransfersModel {
  final int? id;
  final String fromWarehouseId;
  final String toWarehouseId;
  final DateTime? transferDate;
  final DateTime? createdAt;

  const ProductTransfersModel({
    this.id,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    this.createdAt,
    this.transferDate,
  });

  factory ProductTransfersModel.fromJson(Map<String, dynamic> json) {
    return ProductTransfersModel(
      id: json['id'] as int?,
      fromWarehouseId: json['from_warehouse_id'] as String,
      toWarehouseId: json['to_warehouse_id'] as String,
      transferDate: json['transfer_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_warehouse_id': fromWarehouseId,
      'to_warehouse_id': toWarehouseId,
      'transfer_date': transferDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ProductTransfersModel copyWith({
    int? id,
    String? fromWarehouseId,
    String? toWarehouseId,
    DateTime? transferDate,
    DateTime? createdAt,
  }) {
    return ProductTransfersModel(
      id: id ?? this.id,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      transferDate: transferDate ?? this.transferDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ProductTransfersModel(id: $id ,from_warehouse_id: $fromWarehouseId,  to_warehouse_id: $toWarehouseId, created_at: $createdAt, payment_date: $transferDate)';
  }
}