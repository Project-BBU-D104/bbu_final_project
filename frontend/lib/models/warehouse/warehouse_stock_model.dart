class WarehouseStockModel {
  final int? id;
  final int productId;
  final int warehouseId;
  final int qty;

  const WarehouseStockModel({
    this.id,
    required this.productId,
    required this.warehouseId,
    this.qty = 0,
  });

  factory WarehouseStockModel.fromJson(Map<String, dynamic> json) {
    return WarehouseStockModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      qty: json['qty'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'qty': qty,
    };
  }

  WarehouseStockModel copyWith({
    int? id,
    int? productId,
    int? warehouseId,
    int? qty,
  }) {
    return WarehouseStockModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      qty: qty ?? this.qty,
    );
  }

  @override
  String toString() {
    return 'WarehouseStockModel(id: $id, productId: $productId, warehouseId: $warehouseId, qty: $qty)';
  }
}