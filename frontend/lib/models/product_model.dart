class ProductModel {
  final int? id;
  final String categoryId;
  final String supplierId;
  final String? name;
  final String? barcode;
  final String? description;
  final String? photo;
  final String? costPrice;
  final String? salePrice;
  final String unit;
  final int? qty;
  final bool? allowInsertQty;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    this.id,
    required this.categoryId,
    required this.supplierId,
    this.name,
    this.barcode,
    this.photo,
    this.description,
    this.qty,
    this.allowInsertQty,
    required this.unit,
    this.costPrice,
    this.salePrice,
    this.createdAt,
    this.paymentDate,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      categoryId: json['category_id'] as String,
      supplierId: json['supplier_id'] as String,
      name: json['name'] as String?,
      barcode: json['barcode'] as String?,
      photo: json['photo'] as String?,
      description: json['description'] as String?,
      allowInsertQty: json['allow_insert_qty'] as bool?,
      qty: json['qty'] as int?,
      unit: json['unit'] as String,
      costPrice: json['cost_price'] as String?,
      salePrice: json['sale_price'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
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
      'category_id': categoryId,
      'supplier_id': supplierId,
      'name': name,
      'barcode': barcode,
      'cost_price': costPrice,
      'description': description,
      'sale_price': salePrice,
      'unit': unit,
      'allow_insert_qty': allowInsertQty,
      'qty': qty,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    String? categoryId,
    String? supplierId,
    String? name,
    String? barcode,
    String? costPrice,
    String? salePrice,
    bool? allowInsertQty,
    String? qty,
    String? unit,
    String? description,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      allowInsertQty: allowInsertQty ?? this.allowInsertQty,
      qty: this.qty,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, description: $description,unit: $unit ,category_id: $categoryId, allow_insert_qty: $allowInsertQty, qty: $qty, supplier_id: $supplierId, name: $name, barcode: $barcode, cost_price: $costPrice, created_at: $createdAt, updated_at: $updatedAt, payment_date: $paymentDate, photo: $photo, sale_price: $salePrice)';
  }
}