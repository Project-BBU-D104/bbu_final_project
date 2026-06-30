class PurchaseItemModel {
  final int? id;
  final int purchaseId;
  final int productId;

  final int qty;
  final double costPrice;
  final double subtotal;

  const PurchaseItemModel({
    this.id,
    required this.purchaseId,
    required this.productId,
    required this.qty,
    required this.costPrice,
    required this.subtotal,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'] as int?,
      purchaseId: json['purchase_id'] as int,
      productId: json['product_id'] as int,
      qty: json['qty'] as int,
      costPrice: (json['cost_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'qty': qty,
      'cost_price': costPrice,
      'subtotal': subtotal,
    };
  }

  PurchaseItemModel copyWith({
    int? id,
    int? purchaseId,
    int? productId,
    int? qty,
    double? costPrice,
    double? subtotal,
  }) {
    return PurchaseItemModel(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      costPrice: costPrice ?? this.costPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  String toString() {
    return 'PurchaseItemModel(id: $id, purchaseId: $purchaseId, productId: $productId, qty: $qty, subtotal: $subtotal)';
  }
}