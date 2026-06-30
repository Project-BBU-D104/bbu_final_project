class SaleItemModel {
  final int? id;
  final int saleId;
  final int productId;

  final int qty;
  final double salePrice;
  final double subtotal;

  const SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.qty,
    required this.salePrice,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as int?,
      saleId: json['sale_id'] as int,
      productId: json['product_id'] as int,
      qty: json['qty'] as int,
      salePrice: (json['sale_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'qty': qty,
      'sale_price': salePrice,
      'subtotal': subtotal,
    };
  }

  SaleItemModel copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? qty,
    double? salePrice,
    double? subtotal,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      salePrice: salePrice ?? this.salePrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  String toString() {
    return 'SaleItemModel(id: $id, saleId: $saleId, productId: $productId, qty: $qty, subtotal: $subtotal)';
  }
}