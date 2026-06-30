class StockAdjustmentsModels {
  final int? id;
  final String productId;
  final String warehouseId;
  final String userId;
  final String adjustmentType;
  final int qty;
  final int previousQty;
  final int newQty;
  final String reason;
  final String referenceNo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockAdjustmentsModels({
    this.id,
    required this.productId,
    required this.warehouseId,
    required this.userId,
    required this.adjustmentType,
    required this.qty,
    required this.previousQty,
    required this.newQty,
    required this.reason,
    required this.referenceNo,
    this.createdAt,
    this.updatedAt,
  });

  factory StockAdjustmentsModels.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentsModels(
      id: json['id'] as int?,
      productId: json['product_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      userId: json['user_id'] as String,
      adjustmentType: json['adjustment_type'] as String,
      qty: json['qty'] as int,
      previousQty: json['previous_qty'] as int,
      newQty: json['new_qty'] as int,
      reason: json['reason'] as String,
      referenceNo: json['reference_no'] as String,
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
      'product_id': productId,
      'warehouse_id': warehouseId,
      'adjustment_type': adjustmentType,
      'user_id': userId,
      'qty': qty,
      'previous_qty': previousQty,
      'new_qty': newQty,
      'reason': reason,
      'reference_no': referenceNo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  StockAdjustmentsModels copyWith({
    int? id,
    String? productId,
    String? warehouseId,
    String? adjustmentType,
    String? userId,
    int? qty,
    int? previousQty,
    int? newQty,
    String? reason,
    String? referenceNo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockAdjustmentsModels(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      adjustmentType: adjustmentType ?? this.adjustmentType,
      userId: userId ?? this.userId,
      qty: qty ?? this.qty,
      previousQty: previousQty ?? this.previousQty,
      newQty: newQty ?? this.newQty,
      reason: reason ?? this.reason,
      referenceNo: referenceNo ?? this.referenceNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StockAdjustmentsModels(id: $id, reference_no: $referenceNo, reason: $reason ,new_qty: $newQty,previous_qty: $previousQty ,qty: $qty,product_id: $productId, adjustment_type: $adjustmentType, user_id: $userId, warehouse_id: $warehouseId)';
  }
}